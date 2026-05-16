#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

require_root

log::banner "Apps" "Gaming stack (Steam, wine, gamemode)"

if ! grep -q '^\[multilib\]' /etc/pacman.conf; then
    die "[multilib] not enabled in /etc/pacman.conf — run system/pacman.sh first"
fi

log::info "Installing gaming packages"
sudo pacman -S --needed --noconfirm \
    steam lutris \
    wine wine-mono wine-gecko winetricks \
    gamemode lib32-gamemode \
    mangohud lib32-mangohud

log::ok "Gaming stack installed"
