#!/bin/bash

# Set variable
line_left="==========>"

# -----> Start <-----

# Update keys
echo $line_left "Atualizando chaves"
#sudo pacman-key --init && sudo pacman-key --populate && sudo pacman -Sy archlinux-keyring python3 python-pipx neofetch

# Install packages
echo $line_left "Instalando alguns pacotes"
#sudo pacman -S --needed base-devel
#sudo pacman -S unzip htop git alacritty zsh wget lxappearance  nvim lutris

echo $line_left "Instalando display manager"
#sudo pacman -S lightdm lightdm-gtk-greeter --needed
echo $line_left "Habilitando Lightdm"
#sudo systemctl enable lightdm
# /etc/lightdm/lightdm-gtk-greeter.conf copy file

echo $line_left "Instalando pacotes para o i3"
#sudo pacman -S rofi polybar feh dusnt rxvt-unicode

echo $line_left "Instalando Themas"
#sudo pacman -S arc-gtk-theme papirus-icon-theme

echo $line_left "Instalando fontes"
#sudo pacman -S ttf-roboto-mono-nerd ttf-jetbrains-mono-nerd ttf-firacode-nerd 

echo $line_left "Instalando Paru"
#mkdir git && cd git && git clone https://aur.archlinux.org/paru.git && cd paru && makepkg -si && cd

# Instalando pacotes do AUR/Paru

paru -S microsoft-edge-dev-bin visual-studio-code-bin trilium-bin teamviewer
# systemctl start teamviewerd.service

# Configurando ZSH
# sh -c "$(wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"

# Lutris
#sudo pacman -S --needed wine-staging giflib lib32-giflib libpng lib32-libpng libldap lib32-libldap gnutls lib32-gnutls \
#mpg123 lib32-mpg123 openal lib32-openal v4l-utils lib32-v4l-utils libpulse lib32-libpulse libgpg-error \
#lib32-libgpg-error alsa-plugins lib32-alsa-plugins alsa-lib lib32-alsa-lib libjpeg-turbo lib32-libjpeg-turbo \
#sqlite lib32-sqlite libxcomposite lib32-libxcomposite libxinerama lib32-libgcrypt libgcrypt lib32-libxinerama \
#ncurses lib32-ncurses ocl-icd lib32-ocl-icd libxslt lib32-libxslt libva lib32-libva gtk3 \
#lib32-gtk3 gst-plugins-base-libs lib32-gst-plugins-base-libs vulkan-icd-loader lib32-vulkan-icd-loader