#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

USER_NAME="${USER_NAME:-${SUDO_USER:-$USER}}"

require_root

log::banner "AUR" "paru (AUR helper)"

if ! id "$USER_NAME" >/dev/null 2>&1; then
    die "User $USER_NAME doesn't exist"
fi

if command -v paru >/dev/null 2>&1; then
    log::skip "paru already installed"
else
    log::info "Building paru as $USER_NAME"
    sudo pacman -S --needed --noconfirm base-devel git
    sudo -u "$USER_NAME" -H bash -c '
        set -e
        cd /tmp
        rm -rf paru
        git clone https://aur.archlinux.org/paru.git
        cd paru
        makepkg -si --noconfirm
    '
    log::ok "paru installed"
fi

if [[ ${#AUR_PKGS[@]:-0} -gt 0 ]]; then
    log::info "Installing AUR packages: ${AUR_PKGS[*]}"
    sudo -u "$USER_NAME" -H paru -S --needed --noconfirm "${AUR_PKGS[@]}"
    log::ok "AUR packages installed"
fi
