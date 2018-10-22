# dribble
Dribble is a simple project I developed to play with some tools I had laying around.
The purpose of dribble was to develop a way for stealing Wi-Fi passwords by exploiting web browser's cache.
Dribble creates a fake Wi-Fi access point and waits for clients to connect to it. When clients connects, dribble intercepts every HTTP requests perform JavaScript code and inject a malicious JavaScipt code. The malicious JavaScript code is also cached so that it persists when clients disconnect. When the client disconnects and reconnects back to his\her home router, the malicious JavaScript code activates, steals the Wi-Fi password from the router and send it back to the attacker.

Requirements:
* hostapd
* dnsmasq
* node.js
* bettercap

## Installation

TBD

## Usage

TBD
