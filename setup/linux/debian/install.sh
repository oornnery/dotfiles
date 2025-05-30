#!/bin/bash

# Debian/Ubuntu Installation Script for Dotfiles
# Supports: Debian 11+, Ubuntu 20.04+

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Update package lists
log "Updating package lists..."
sudo apt update

# Install essential packages
log "Installing essential packages..."
sudo apt install -y \
    curl \
    wget \
    git \
    vim \
    neovim \
    zsh \
    tmux \
    htop \
    tree \
    unzip \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release

# Install development tools
log "Installing development tools..."
sudo apt install -y \
    build-essential \
    python3 \
    python3-pip \
    python3-venv \
    nodejs \
    npm \
    golang

# Install window manager packages (optional)
if command -v rofi &> /dev/null; then
    log "Installing WM packages..."
    sudo apt install -y \
        i3-wm \
        i3status \
        i3lock \
        rofi \
        feh \
        compton \
        dunst \
        alacritty
fi

# Install Flatpak
log "Installing Flatpak..."
sudo apt install -y flatpak
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Install Snap (if not present)
if ! command -v snap &> /dev/null; then
    log "Installing Snap..."
    sudo apt install -y snapd
fi

# Python development setup
log "Setting up Python development environment..."
python3 -m pip install --user --upgrade pip
python3 -m pip install --user pipx
python3 -m pipx ensurepath

# Install common Python packages
python3 -m pipx install poetry
python3 -m pipx install black
python3 -m pipx install flake8
python3 -m pipx install mypy

log "Debian setup completed successfully!"
log "Reboot may be required for some changes to take effect."
