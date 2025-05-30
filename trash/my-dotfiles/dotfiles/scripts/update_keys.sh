#!/bin/bash

# update keys ring

echo "Atualizando chaves\n"
sudo pacman-key --init && sudo pacman-key --populate archlinux && sudo pacman -Sy archlinux-keyring
