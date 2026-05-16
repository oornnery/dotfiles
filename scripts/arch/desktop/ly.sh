#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../lib/detect.sh"

require_root
detect::system

log::banner "Desktop" "ly display manager"

if [[ $IS_WSL -eq 1 || $IS_VM -eq 1 ]]; then
    log::skip "WSL/VM: no display manager needed"
    exit 0
fi

log::info "Installing ly"
sudo pacman -S --needed --noconfirm ly

log::info "Disabling other display managers"
for unit in gdm.service sddm.service greetd.service; do
    if systemctl is-enabled --quiet "$unit" 2>/dev/null; then
        sudo systemctl disable --now "$unit" || true
        log::ok "Disabled $unit"
    fi
done

sudo systemctl enable ly.service

log::ok "ly enabled"
