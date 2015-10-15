#!/bin/bash
# Requirements: hostapd, dnsmasq
# Install:
# apt-get install hostapd
# apt-get install dnsmasq

if test "$1" == "" ; then
	echo $'\a'Please specify wireless device, e.g:
	echo $0 wlan0
	exit
fi

ifconfig $1 up
ifconfig $1 192.168.1.1/24

cat <<EOF > /etc/dnsmasq.conf
no-resolv
interface=$1
dhcp-range=192.168.1.2,192.168.1.5,255.255.255.0,12h
EOF

sudo service dnsmasq restart

cat <<EOF > /etc/hostapd/hostapd.conf
interface=$1
driver=nl80211
bssid=90:03:B7:00:00:00
ssid=arclone2_000000
channel=1
ctrl_interface=/var/run/hostapd
ctrl_interface_group=0
EOF

sudo hostapd -d /etc/hostapd/hostapd.conf
