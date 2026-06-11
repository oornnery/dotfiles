#!/usr/bin/env bash
# core/wsl.sh — WSL /etc/wsl.conf via stow.
#
# Config lives at ~/dotfiles/wsl/etc/wsl.conf and is linked to
# /etc/wsl.conf by `stow_system wsl`. Edit the file directly in the
# repo, then `wsl --shutdown` from PowerShell to reload.

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../lib/detect.sh"

require_root
detect::system

log::banner "WSL" "Base setup (/etc/wsl.conf)"

if [[ $IS_WSL -eq 0 ]]; then
    log::skip "Not running in WSL"
    exit 0
fi

stow_system wsl

log::warn "From PowerShell: 'wsl --shutdown' then reopen Arch"
