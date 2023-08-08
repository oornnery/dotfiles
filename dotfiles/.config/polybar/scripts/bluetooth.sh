#!/bin/bash
sudo pacman -S bluez bluez-utils bluez-tools blueman 

sudo nano /etc/bluetooth/main.conf

procure a linha AutoEnable=false e mude para AutoEnable=true

depois 
sudo systemctl start bluetooth.service
sudo systemctl enable bluetooth.service