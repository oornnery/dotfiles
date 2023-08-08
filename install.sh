#!/bin/bash


packages_base=$(cat dotfiles/packages_.txt)
packages_dev=$(cat dotfiles/packages_dev.txt)
packages_extras=$(cat dotfiles/packages_extras.txt)
packages_scripts=$(cat dotfiles/packages_scripts.txt)
user=$(whoami)



# Atualizando sistema
pacman -Syyu

# Instalando pacotes base
pacman -S < $packages_base --needed --noconfirm

# Instalando pacotes de desenvolvimento
pacman -S < $packages_dev --needed --noconfirm

# Instalando pacotes extras
pacman -S < $packages_extras --needed --noconfirm


# Fazendo backup dos arquivos de configuração 

mkdir -p dotfiles/backup/$user

cp -r ~/.config dotfiles/backup/$user

# Copiando arquivos de configuração 
cp -r ./dotfiles/.config ~/.config
