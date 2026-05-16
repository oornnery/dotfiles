#!/usr/bin/env bash
# core/networkmanager.sh — NetworkManager + optional iwd backend.
#
# When USE_IWD=1 (default), installs iwd + impala (TUI) and stows the
# iwd/ package, which links /etc/NetworkManager/conf.d/wifi_backend.conf
# to the repo. Set USE_IWD=0 in arch.conf to stay on wpa_supplicant.

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../lib/detect.sh"

USE_IWD="${USE_IWD:-1}"

require_root
detect::system

log::banner "Core" "NetworkManager"

if [[ $IS_WSL -eq 1 ]]; then
    log::skip "WSL: networking is managed by Windows host"
    exit 0
fi

log::info "Installing NetworkManager"
sudo pacman -S --needed --noconfirm networkmanager network-manager-applet

sudo systemctl enable NetworkManager.service

if [[ "$USE_IWD" == "1" ]]; then
    log::info "Switching wifi backend to iwd (+ impala TUI)"
    sudo pacman -S --needed --noconfirm iwd impala

    stow_system iwd

    log::info "Restarting NetworkManager to pick up the new backend"
    sudo systemctl restart NetworkManager.service || \
        log::warn "NetworkManager restart failed — reboot to apply"
else
    log::skip "USE_IWD=0 — staying on wpa_supplicant"
fi

log::ok "NetworkManager configured"
