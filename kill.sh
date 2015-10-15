#!/bin/bash
sudo service network-manager stop
sudo service avahi-daemon stop
pgrep NetworkManager
pgrep dhclient
pgrep wpa_supplicant
pgrep avahi-daemon
sudo pkill NetworkManager
sudo pkill dhclient
sudo pkill wpa_supplicant
sudo pkill avahi-daemon
pgrep NetworkManager
pgrep dhclient
pgrep wpa_supplicant
pgrep avahi-daemon

