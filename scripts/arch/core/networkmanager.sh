#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../lib/detect.sh"

USE_IWD="${USE_IWD:-0}"
TEMPLATES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../templates" && pwd)"

require_root
detect::system

log::banner "Core" "NetworkManager"

if [[ $IS_WSL -eq 1 ]]; then
    log::skip "WSL: networking is managed by Windows host"
    exit 0
fi

log::info "Installing NetworkManager"
sudo pacman -S --needed --noconfirm \
    networkmanager network-manager-applet

sudo systemctl enable NetworkManager.service

if [[ $USE_IWD -eq 1 ]]; then
    log::info "Switching wifi backend to iwd"
    sudo pacman -S --needed --noconfirm iwd impala

    src="$TEMPLATES_DIR/etc/NetworkManager/conf.d/wifi_backend.conf"
    dest=/etc/NetworkManager/conf.d/wifi_backend.conf

    if [[ -f "$src" ]]; then
        sudo install -d -m 755 /etc/NetworkManager/conf.d
        sudo install -m 644 "$src" "$dest"
        log::ok "Installed $dest"
    else
        log::warn "Template missing: $src"
    fi
fi

log::ok "NetworkManager installed"
