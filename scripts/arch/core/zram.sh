#!/usr/bin/env bash
# core/zram.sh — compressed RAM swap via zram-generator.
#
# Config lives at ~/dotfiles/zram/etc/systemd/zram-generator.conf and
# is linked to /etc/systemd/zram-generator.conf by `stow_system zram`.
# Edit the file in the repo to change zram-size / algorithm / priority.

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../lib/detect.sh"

require_root
detect::system

log::banner "Core" "zram swap"

if [[ $IS_VM -eq 1 ]]; then
    log::skip "VM: host already manages memory; zram is redundant"
    exit 0
fi
if [[ $IS_WSL -eq 1 ]]; then
    log::skip "WSL: memory is managed by the Windows host"
    exit 0
fi

log::info "Installing zram-generator"
sudo pacman -S --needed --noconfirm zram-generator

stow_system zram

# Activate immediately (no reboot needed). zram-generator creates a
# transient systemd unit per [zram*] section in the conf file.
log::info "Activating /dev/zram0"
sudo systemctl daemon-reload
sudo systemctl restart systemd-zram-setup@zram0.service \
    || log::warn "zram setup restart failed — reboot to apply"

# Show the result.
if command -v zramctl >/dev/null; then
    log::ok "$(zramctl --output NAME,ALGORITHM,DATA,COMPR,TOTAL | tail -n +1)"
fi

log::ok "zram configured (zstd, size = total RAM)"
