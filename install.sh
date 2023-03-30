#!/bin/bash

# Imports

# Set variable
line_left="===>"
data=$(date +"%T")


# Funções
call_taks() {
    # $1 = string da task
    # $1 = task para ser chamadas
    echo -e "\e[32m$data :: ===> $1 \e[1;34m(yes ou no):\e[0m\n"
    read resp

    if [ "$resp" = "yes" ] || [ "$resp" = "y" ]
    then
        echo -e "\e[34m$data :: ===> Starting task.\e[0m\n"
        $2
    elif [ "$resp" = "no" ] || [ "$resp" = "n" ]
    then
        echo -e "\e[34m$data :: ===> Skipped task.\e[0m\n"
    else
        echo -e "\e[31m$data :: ===> Select a valid option.\e[0m\n"
        call_taks "$1" $2
    fi
}

update_key() {
    echo -e "\e[34m Atualizando chaves.\e[0m\n"
    sudo pacman-key --init --populate && sudo pacman -Sy archlinux-keyring
}

update_base_devel() {
    echo -e "\e[34m Atualizando base-devel.\e[0m\n"
    sudo pacman -S --needed base-devel
}

install_essential_packages() {
    echo -e "\e[34m$date :: ===> Instalando pacotes essenciais.\e[0m\n"
    sudo pacman -S unzip htop git alacritty zsh wget nvim neofetch python3 python-pipx obsidian discord
    sh -c "$(wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"
    
    echo -e "\n\e[34m$date :: ===> Instalando AUR/Paru.\e[0m\n"
    mkdir git && cd git && git clone https://aur.archlinux.org/paru.git && cd paru && makepkg -si && cd

    echo -e "\n\e[34m$date :: ===> Instalando pacotes do AUR.\e[0m\n"
    paru -S microsoft-edge-dev-bin visual-studio-code-bin teamviewer
    systemctl enable teamviewerd.service
    systemctl start teamviewerd.service
}


# -----> Start <-----
# Update key
call_taks "Deseja atualizar as chaves?" update_key

# Atualizando base-devel
call_taks "Deseja atualizar o pacote base-devel?" update_base_devel

# Instalando pacotes essenciais.
call_taks "Deseja instalar os pacotes essenciais?" install_essential_packages



# echo $line_left "Instalando display manager"
# sudo pacman -S lightdm lightdm-gtk-greeter --needed
# sudo systemctl enable lightdm
# # /etc/lightdm/lightdm-gtk-greeter.conf copy file

# echo $line_left "Instalando pacotes para o i3"
# #sudo pacman -S i3-wm lxappearance rofi polybar feh dusnt 

# echo $line_left "Instalando Themas"
# sudo pacman -S arc-gtk-theme papirus-icon-theme

# echo $line_left "Instalando fontes"
# sudo pacman -S ttf-roboto-mono-nerd ttf-jetbrains-mono-nerd ttf-firacode-nerd

# lutris
# sudo pacman -S --needed nvidia-dkms nvidia-utils lib32-nvidia-utils nvidia-settings vulkan-icd-loader lib32-vulkan-icd-loader

# sudo pacman -S --needed wine-staging giflib lib32-giflib libpng lib32-libpng libldap lib32-libldap gnutls lib32-gnutls mpg123 lib32-mpg123 openal lib32-openal v4l-utils lib32-v4l-utils libpulse lib32-libpulse libgpg-error lib32-libgpg-error alsa-plugins lib32-alsa-plugins alsa-lib lib32-alsa-lib libjpeg-turbo lib32-libjpeg-turbo sqlite lib32-sqlite libxcomposite lib32-libxcomposite libxinerama lib32-libgcrypt libgcrypt lib32-libxinerama ncurses lib32-ncurses ocl-icd lib32-ocl-icd libxslt lib32-libxslt libva lib32-libva gtk3 lib32-gtk3 gst-plugins-base-libs lib32-gst-plugins-base-libs vulkan-icd-loader lib32-vulkan-icd-loader