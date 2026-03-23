#!/usr/bin/env bash
set -euo pipefail

# Run after fresh Debian install

# Install nala first
sudo apt update
sudo apt install -y nala

# Use nala from now on
sudo nala update
sudo nala upgrade -y

# Install base packages
sudo nala install -y \
  build-essential ninja-build cmake make gettext \
  curl wget git gh vim zsh tmux \
  fastfetch jq tree htop btop \
  unzip zip tar gzip bzip2 xz-utils \
  openssl openssh-client ca-certificates \
  fzf ripgrep fd-find bat stow \
  python3 python3-pip \
  nodejs npm \
  golang rustc cargo nim lua5.4 luarocks \
  docker.io docker-compose

# Fix common Debian naming differences

# fd -> fd-find
if ! command -v fd >/dev/null 2>&1; then
  mkdir -p ~/.local/bin
  ln -sf "$(command -v fdfind)" ~/.local/bin/fd
fi

# bat -> batcat
if command -v batcat >/dev/null 2>&1 && ! command -v bat >/dev/null 2>&1; then
  mkdir -p ~/.local/bin
  ln -sf "$(command -v batcat)" ~/.local/bin/bat
fi

# Install eza
cargo install eza

# Install Neovim (latest stable)
rm -rf /tmp/neovim
git clone --depth 1 --branch stable https://github.com/neovim/neovim /tmp/neovim

(
  cd /tmp/neovim
  make CMAKE_BUILD_TYPE=Release
  sudo make install
)

rm -rf /tmp/neovim

# Install modern dev tools

# uv
curl -LsSf https://astral.sh/uv/install.sh | sh

# bun
curl -fsSL https://bun.sh/install | bash

# pnpm
curl -fsSL https://get.pnpm.io/install.sh | sh -

# ruff / ty / rumdl
if command -v uv >/dev/null 2>&1; then
  uv tool install ruff ty rumdl || true
else
  pip install --user ruff ty rumdl || true
fi

echo
echo "Debian setup finished."
echo
echo "Next steps:"
echo "  ./stow.sh"
echo "  ./zsh.sh"
echo