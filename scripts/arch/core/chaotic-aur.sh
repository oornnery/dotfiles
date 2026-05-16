#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

require_root

log::banner "AUR" "Chaotic-AUR repo"

if grep -q '^\[chaotic-aur\]' /etc/pacman.conf; then
    log::skip "Chaotic-AUR already configured"
    exit 0
fi

log::info "Receiving Chaotic-AUR key"
sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
sudo pacman-key --lsign-key 3056513887B78AEB

log::info "Installing chaotic-keyring + mirrorlist"
sudo pacman -U --noconfirm \
    'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' \
    'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'

log::info "Adding [chaotic-aur] section to /etc/pacman.conf"
snapshot /etc/pacman.conf
sudo tee -a /etc/pacman.conf >/dev/null <<'EOF'

[chaotic-aur]
Include = /etc/pacman.d/chaotic-mirrorlist
EOF

sudo pacman -Sy

log::ok "Chaotic-AUR enabled"
