#!/usr/bin/env bash
set -euo pipefail

# Install paru (AUR helper)

# Install base-devel if needed
sudo pacman -S --needed --noconfirm base-devel git

# Skip if already installed
if command -v paru >/dev/null 2>&1; then
  echo "paru already installed"
  exit 0
fi

# Build paru
rm -rf /tmp/paru
git clone https://aur.archlinux.org/paru.git /tmp/paru

(
  cd /tmp/paru
  makepkg -si --noconfirm
)

rm -rf /tmp/paru

echo "paru installed"