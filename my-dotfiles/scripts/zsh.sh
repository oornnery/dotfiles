#!/bin/bash

source utils.sh

$ARCH_PACKAGE='zsh,curl,git'
$DEBIAN_PACKAGE='zsh,curl,git'
install_package $ARCH_PACKAGE $DEBIAN_PACKAGE

# Install oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Install zap plugin manager
zsh <(curl -s https://raw.githubusercontent.com/zap-zsh/zap/master/install.zsh) --branch release-v1

# Install plugins
# https://github.com/hlissner/zsh-autopair
# https://github.com/zap-zsh/supercharge
# https://github.com/zap-zsh/vim
# https://github.com/zap-zsh/completions
# https://github.com/zap-zsh/sudo
# https://github.com/Aloxaf/fzf-tab
# https://github.com/wintermi/zsh-lsd
# https://github.com/tm4Bit/fzf-zellij
# https://github.com/zsh-users/zsh-autosuggestions
# https://github.com/zsh-users/zsh-syntax-highlighting
# https://github.com/zsh-users/zsh-completions

# Copy .zshrc
cp $DOTFILES_PATH/zsh/.zshrc $HOME/.zshrc