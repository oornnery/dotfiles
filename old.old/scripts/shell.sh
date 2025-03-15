#!/bin/bash

# Terminal
sudo pacman -S zsh alacritty tmux ranger bat lsd fzf fd ripgrep sd dust tldr glaces thefuck ncdu tokei asciinema github-cli

### ZSH shell setup
cp ~/.zshrc ~/.zshrc.old

# Oh my ZSH
curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | bash -s

# zinit plugin manager
curl -fsSL https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh | bash -s
# zinit light zsh-users/zsh-autosuggestions
# zinit light zsh-users/zsh-syntax-highlighting
# zinit light zdharma-continuum/fast-syntax-highlighting

# oh my posh
# curl -fsSL https://ohmyposh.dev/install.sh | bash -s
# echo 'eval "$(oh-my-posh init zsh)"' >> ~/.zshrc

chsh -s $(which zsh)
