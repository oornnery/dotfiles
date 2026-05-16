#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../lib/detect.sh"

require_root
detect::system
detect::bluetooth

log::banner "Hardware" "Bluetooth"

if [[ $IS_WSL -eq 1 ]]; then
    log::skip "WSL: Bluetooth not supported"
    exit 0
fi

if [[ $HAS_BLUETOOTH -eq 0 ]]; then
    log::warn "No Bluetooth hardware detected"
    exit 0
fi

log::info "Installing Bluetooth stack"
sudo pacman -S --needed --noconfirm \
    bluez bluez-utils bluez-obex blueman \
    bluetui

if [[ $IS_VM -eq 0 && -f /etc/bluetooth/main.conf ]]; then
    if grep -q '^Experimental = true' /etc/bluetooth/main.conf; then
        log::skip "bluetooth Experimental already enabled"
    else
        snapshot /etc/bluetooth/main.conf
        sudo sed -i 's/^#\?\s*Experimental.*$/Experimental = true/' /etc/bluetooth/main.conf
        log::ok "Enabled bluetooth Experimental (battery report)"
    fi
fi

sudo systemctl enable bluetooth.service

log::ok "Bluetooth configured"
