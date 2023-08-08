#!/bin/bash

clear
echo -e "\e]34m :: ===> Starting task.\e[0m\n"
echo -e "\e]34m :: ===> Update base-devel.\e[0m\n"
sudo pacman -S --needed base-devel
echo -e "\e]34m :: ===> cd /opt/.\e[0m\n"
cd /opt/
echo -e "\e]34m :: ===> Clone package.\e[0m\n"
git clone https://aur.archlinux.org/paru.git
cd paru
echo -e "\e]34m :: ===> Make package.\e[0m\n"
makepkg -si
echo -e "\e]34m :: ===> Finishing task.\e[0m\n"
