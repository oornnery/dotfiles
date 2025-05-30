#!/bin/bash

# Configure bluetooth

# Install bluetooth
echo "Install bluetooth packages\n"

paru -S bluez bluez-cups bluez-hid2hci bluez-libs bluez-plugins bluez-tools bluez-utils broadcom-bt-firmware-git pulseaudio-bluetooth blueman blueberry

# Enable bluetooth
echo "Enabled bluetooth.service\n"
sudo systemctl enable bluetooth.service
sudo systemctl start bluetooth.service

# Install rofi-bluetooth
echo "Install rofi-bluetooth"
# paru -S rofi-bluetooth

echo "https://wiki.archlinux.org/title/bluetooth#Installation"

# https://wiki.archlinux.org/title/bluetooth#Installation
# https://github.com/nickclyde/rofi-bluetooth
