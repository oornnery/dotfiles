#!/usr/bin/bash

# Install Python and related tools
sudo apt install nala

sudo nala update

sudo nala install -y \
  make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev \
  libsqlite3-dev libncurses-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev \
  libffi-dev liblzma-dev curl git

sudo nala install -y python3 python3-pip python3-venv python3-neovim

git clone https://github.com/pyenv/pyenv.git ~/.pyenv
cd ~/.pyenv && src/configure && make -C src

