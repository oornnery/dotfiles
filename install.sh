#!/usr/bin/env bash

banner() {

    echo '#----------------------------------------------------------------------------------------------------------#'
    echo '#  ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄  ▄▄        ▄  ▄▄        ▄  ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄  ▄         ▄  #'
    echo '# ▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░░▌      ▐░▌▐░░▌      ▐░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░▌       ▐░▌ #'
    echo '# ▐░█▀▀▀▀▀▀▀█░▌▐░█▀▀▀▀▀▀▀█░▌▐░█▀▀▀▀▀▀▀█░▌▐░▌░▌     ▐░▌▐░▌░▌     ▐░▌▐░█▀▀▀▀▀▀▀▀▀ ▐░█▀▀▀▀▀▀▀█░▌▐░▌       ▐░▌ #'
    echo '# ▐░▌       ▐░▌▐░▌       ▐░▌▐░▌       ▐░▌▐░▌▐░▌    ▐░▌▐░▌▐░▌    ▐░▌▐░▌          ▐░▌       ▐░▌▐░▌       ▐░▌ #'
    echo '# ▐░▌       ▐░▌▐░▌       ▐░▌▐░█▄▄▄▄▄▄▄█░▌▐░▌ ▐░▌   ▐░▌▐░▌ ▐░▌   ▐░▌▐░█▄▄▄▄▄▄▄▄▄ ▐░█▄▄▄▄▄▄▄█░▌▐░█▄▄▄▄▄▄▄█░▌ #'
    echo '# ▐░▌       ▐░▌▐░▌       ▐░▌▐░░░░░░░░░░░▌▐░▌  ▐░▌  ▐░▌▐░▌  ▐░▌  ▐░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌ #'
    echo '# ▐░▌       ▐░▌▐░▌       ▐░▌▐░█▀▀▀▀█░█▀▀ ▐░▌   ▐░▌ ▐░▌▐░▌   ▐░▌ ▐░▌▐░█▀▀▀▀▀▀▀▀▀ ▐░█▀▀▀▀█░█▀▀  ▀▀▀▀█░█▀▀▀▀  #'
    echo '# ▐░▌       ▐░▌▐░▌       ▐░▌▐░▌     ▐░▌  ▐░▌    ▐░▌▐░▌▐░▌    ▐░▌▐░▌▐░▌          ▐░▌     ▐░▌       ▐░▌      #'
    echo '# ▐░█▄▄▄▄▄▄▄█░▌▐░█▄▄▄▄▄▄▄█░▌▐░▌      ▐░▌ ▐░▌     ▐░▐░▌▐░▌     ▐░▐░▌▐░█▄▄▄▄▄▄▄▄▄ ▐░▌      ▐░▌      ▐░▌      #'
    echo '# ▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░▌       ▐░▌▐░▌      ▐░░▌▐░▌      ▐░░▌▐░░░░░░░░░░░▌▐░▌       ▐░▌     ▐░▌      #'
    echo '#  ▀▀▀▀▀▀▀▀▀▀▀  ▀▀▀▀▀▀▀▀▀▀▀  ▀         ▀  ▀        ▀▀  ▀        ▀▀  ▀▀▀▀▀▀▀▀▀▀▀  ▀         ▀       ▀       #'
    echo '#----------------------------------------------------------------------------------------------------------#'
    echo  '# Github : oornnerynho #'
    echo  '# Twitter: oornnerynho #'
    echo  '# Reddit : oornnerynho #'
    echo ''
    echo ''
}

move_file() {
    
}

install_package() {
    local path=$1

    # Verifique se o arquivo existe
    if [ ! -f "$path" ]; then
        echo "file $path not found!"
        return 1
    fi

    while IFS= read -r package; do
        sudo pacman -S "$path"
    done
}



packages_base=$(cat pkg-files/base)
packages_dev=$(cat dotfiles/packages_dev.txt)
packages_extras=$(cat dotfiles/packages_extras.txt)
packages_scripts=$(cat dotfiles/packages_scripts.txt)
user=$(whoami)

echo "
=================================
=         Setup Pacman          =
=================================

"

sudo rm /etc/pacman.conf
sudo cp .config/pacman.conf /etc/pacman.conf


# Fazer backup
# Copiar arquivos de configuração
cp $HOME/.bashrc $HOME/.bashrc.bak
cp $HOME/.zshrc $HOME/.zshrc.bak
cp $HOME/.zsh_history $HOME/.zsh_history.bak
cp $HOME/.p10k.zsh $HOME/.p10k.zsh.bak
cp $HOME/.vimrc $HOME/.vimrc.bak

# Compiar diretorio de configuração
cp -r $HOME/.config $HOME/.config.bak
cp -r $HOME/.oh-my-zsh $HOME/.oh-my-zsh.bak
cp -r $HOME/.wallpaper $HOME/.wallpaper.bak
cp -r $HOME/.scripts $HOME/.scripts.bak
cp -r $HOME/.screenlayout $HOME/.screenlayout.bak


# Instalar pacotes
# Copiar arquivos
# Atualizar



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
cp ./dotfiles/.zshrc ~/
