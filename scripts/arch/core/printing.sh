#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../lib/detect.sh"

require_root
detect::system

log::banner "Core" "Printing (CUPS)"

if [[ $IS_WSL -eq 1 ]]; then
    log::skip "WSL: printing handled by host Windows"
    exit 0
fi

log::info "Installing CUPS stack"
sudo pacman -S --needed --noconfirm \
    cups cups-browsed cups-filters cups-pdf \
    system-config-printer

log::info "Enabling cups.service + cups.socket"
sudo systemctl enable --now cups.socket
sudo systemctl enable --now cups-browsed.service 2>/dev/null || true

log::ok "Printing ready — open system-config-printer to add devices"
