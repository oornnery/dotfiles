#!/bin/bash

# Docker setup
sudo pacman -S docker docker-compose
sudo systemctl enable --now docker
sudo usermod -aG docker $USER

# Virtualization
sudo pacman -S \
    virtualbox \
    virt-manager \
    qemu \
    libvirt \
    edk2-ovmf \
    gnome-boxes
    # TODO: drivers video

# Enviroment
sudo pacman -S \
    nodejs dino yarn npm \
    rust cargo \
    go \
    lua \
    zig \
    cmake

### Python
sudo pacman -S python-pipx bpython
pipx install \
    baca \
    git+https://github.com/darrenburns/elia \
    toolong \
    posting \
    gitignore \
    dolphie \
    dooit \
    rich-cli \
    frogmouth \
    recoverpy \
    poetry \
    ruff \
    pytest \
    isort \
    yamllint \
    pre-commit \
    uv

### GIT
sudo pacman -S git github-cli
paru -S github-desktop-bin

### Git manual
# git config --global user.name "$name"
# git config --global user.email $email

### gh cli
# gh auth login

### Zed editor
curl -f https://zed.dev/install.sh | sh

# IA
sudo pacman -S ollama
paru -S lmstudio
