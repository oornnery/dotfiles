#!/bin/bash
#
# https://github.com/Morganamilo/paru
#
#
sudo pacman -S --needed base-devel
mkdir -p github
git clone https://aur.archlinux.org/paru.git ~/github/paru
cd paru
makepkg -si