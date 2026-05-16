#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../lib/detect.sh"

require_root
detect::system

log::banner "System" "Snapper (btrfs snapshots)"

if [[ "$ROOT_FS" != "btrfs" ]]; then
    log::skip "Root fs is '$ROOT_FS', not btrfs"
    exit 0
fi

log::info "Installing snapper + snap-pac"
sudo pacman -S --needed --noconfirm snapper snap-pac

if sudo snapper -c root list >/dev/null 2>&1; then
    log::skip "Snapper config 'root' already exists"
else
    log::info "Creating snapper config for /"
    sudo snapper -c root create-config / || log::warn "snapper create-config failed (existing subvolume?)"
    log::ok "Snapper config created"
fi

log::ok "Snapper configured (snapshots taken on pacman operations)"
