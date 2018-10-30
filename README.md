# Dribble

Dribble is a project I developed to play with my Raspberry Pie. The purpose of dribble is to stealing Wi-Fi passwords by exploiting web browser's cache. Dribble creates a fake Wi-Fi access point and waits for clients to connect to it. When clients connects, dribble intercepts every HTTP requests performed to JavaScript pages and injects a malicious JavaScipt code. The malicious JavaScript code is cached so that it persists when clients disconnect. When clients disconnect and reconnect back to their home router, the malicious JavaScript code activates, steals the Wi-Fi password from the router and send it back to the attacker.

For a more in-depth walkthrough see here: https://rhaidiz.net/2018/10/25/dribble-stealing-wifi-password-via-browsers-cache-poisoning/

**DISCLAIMER:** this is till a work in progress and a lot of small improvements should be implemented so keep that in mind.

## Installation

### Requirements

Dribble relays on the following software to work, so make sure you have them installed:

* hostapd
* dnsmasq
* node.js
* bettercap

### Download and run

To run dribble, just download the repo and run it as root.

    git clone https://github.com/rhaidiz/dribble
    cd dribble
    sudo ./dribble

## Configuration

At the moment there isn't a proper configuration file for dribble. So customization should be edited direcly from the following files:

* `dribble.sh`: to change the network configuration such as the local subnet of the fake access point and the ESSID
* `dribble.cap`: change it to point to the location of `inject-drible.js` and should also be canghed accordingly if you changed the subnet of the fake access point
* `dnsentries.hosts`: change so that `dribble.poison` points to the IP address of the fake access poing
* `www/js/dlink.js`: to change the end-point where to send the Wi-Fi password
