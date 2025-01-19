# /bin/bash

# Update system
sudo pacman -S --needed base-devel

# Install Paru
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si

# Install packages
sudo pacman -S \
  alacritty \
  unzip \
  git \
  wget \
  curl \
  neovim \
  zsh \
  eza \
  fzf \
  fd \
  thefuck \
  ripgrep \
  bat

# Install development packages
sudo pacman -S \
  git \
  github-cli \
  vagrant \
  python \
  nodejs \
  dino \
  yarn \
  npm \
  rust \
  go \
  lua \
  zig

# Install Docker and Docker Compose
sudo pacman -S \
  docker \
  docker-compose

sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker $USER

# Install AI packages
sudo pacman -S \
  ollama

# Install virtualization packages
sudo pacman -S \
  virtualbox \
  virt-manager \
  qemu \
  libvirt \
  edk2-ovmf \
  gnome-boxes

# Install oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Install ZSH Zap
zsh <(curl -s https://raw.githubusercontent.com/zap-zsh/zap/master/install.zsh) --branch release-v1

# Install NVChad
git clone https://github.com/NvChad/starter ~/.config/nvim && nvim

# Install TUI's
sudo pacman -S \
  htop \
  btop \
  bluetui \
  tui-journal

# Install packages pipx
sudo pacman -S \
  python-pipx

pipx install \
  posting \
  dooit \

# Python developments
pipx install \
  poetry \
  ruff \
  pytest \
  pytest-cov \
  isort \
  yamllint \
  pre-commit \
  uv \
  uvx

# Create files
mkdir $HOME/projects
mkdir $HOME/docker-files
mkdir $HOME/notes

# Install Nerd Fonts
# paru -S nerd-fonts-fira-code

# Install games packages
sudo pacman -S \
  steam \
  lutris \
  wine \

paru -S \
  curseforge \
  heroic-games-launcher \
  minecraft-launche

# Install other packages
sudo pacman -S \
  vivialdi \
  obsidian \
  notion \
  discord \
  telegram-desktop \
  obs-studio \
  vlc \
  flameshot \
  libreoffice \
  gimp \
  inkscape \
  kdenlive \
  audacity \
  blender \
  qbittorrent \
  obs-studio
  # krita \ # Alternative to GIMP
  # shotcut \ # Alternative to Kdenlive

paru -S \
  slack-desktop \
  siyuan \
  marktext \
  anki

# siyuan Notion alternative

