#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

require_root

log::banner "Hardware" "Printing (CUPS)"

log::info "Installing CUPS"
sudo pacman -S --needed --noconfirm \
    cups cups-filters cups-pdf system-config-printer

sudo systemctl enable cups.service
sudo systemctl enable cups.socket

log::ok "CUPS printing configured"
