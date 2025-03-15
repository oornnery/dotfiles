#!/bin/bash

git clone https://aur.archlinux.org/paru.git ~/.local/share/paru && (cd ~/.local/share/paru && makepkg -si)
