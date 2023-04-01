#!/bin/bash
#
echo "Instalando pacotes bluez bluez-utils blueman"
sudo pacman -S bluez bluez-utils blueman pulseaudio-bluetooth

echo "Ativando serviço"
sudo systemctl enable bluetooth.service
sudo systemctl start bluetooth.service

echo -e "\nadicione no .config/i3/config"
echo "exec --no-startup-id blueman"

# https://github.com/nickclyde/rofi-bluetooth
