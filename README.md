# Dribble

Dribble is a project I developed to play with my Raspberry Pi. The purpose of dribble is to stealing Wi-Fi passwords by exploiting web browser's cache. Dribble creates a fake Wi-Fi access point and waits for clients to connect to it. When clients connects, dribble intercepts every HTTP requests performed to JavaScript pages and injects a malicious JavaScipt code. The malicious JavaScript code is cached so that it persists when clients disconnect. When clients disconnect and reconnect back to their home router, the malicious JavaScript code activates, steals the Wi-Fi password from the router and send it back to the attacker.

For a more in-depth walkthrough see here: https://rhaidiz.net/2018/10/25/dribble-stealing-wifi-password-via-browsers-cache-poisoning/

**DISCLAIMER:** this is till a work in progress and a lot of small improvements should be implemented so keep that in mind.

## Installation

### Requirements

Dribble relays on the following software to work, so make sure you have them installed and available in your PATH:

* [hostapd](https://github.com/wertarbyte/hostap/tree/master/hostapd)
* [dnsmasq](http://www.thekelleys.org.uk/dnsmasq/doc.html)
* [node.js](https://nodejs.org/en/download/package-manager/)
* [bettercap](https://github.com/bettercap/bettercap)

### Download and run

To run dribble, just download the repo and run it as root.

    git clone https://github.com/rhaidiz/dribble
    cd dribble
    sudo ./dribble

## Configuration

All the configuration you need is located in the config file:

    # the internet interface
    internet=eth0
    
    # the wifi interface
    phy=wlan0
    
    # The ESSID
    essid="TEST"
    
    # collector
    collector="http://rhaidiz.net/something"
    
    # the routers' IPs
    routerips=("192.168.0.1/24" "10.0.0.1/24")
    
    # usernames dictionary
    usernames="['admin', 'admin1', 'test']"
    
    # passwords dictionaris
    passwords="['admin', 'admin1', 'password']"
