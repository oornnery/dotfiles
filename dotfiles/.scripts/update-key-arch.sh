#!/bin/bash

# update key archlinux

update_key() {
    echo "==========#- *Stating update key* -#=========="
    sudo pacman-key --init && sudo pacman-key --populate && sudo pacman -Sy archlinux-keyring
}
