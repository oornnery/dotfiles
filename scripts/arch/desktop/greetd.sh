#!/usr/bin/env bash
# desktop/greetd.sh — greetd + tuigreet, configured via stow.
#
# Config lives at ~/dotfiles/greetd/etc/greetd/config.toml and is linked
# to /etc/greetd/config.toml by `stow_system greetd`. Edit the file in
# the repo and `sudo systemctl restart greetd` to apply.

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../lib/detect.sh"

require_root
detect::system

log::banner "Desktop" "greetd + tuigreet"

if [[ $IS_WSL -eq 1 || $IS_VM -eq 1 ]]; then
    log::skip "WSL/VM: no display manager needed"
    exit 0
fi

log::info "Installing greetd + tuigreet"
sudo pacman -S --needed --noconfirm greetd greetd-tuigreet

log::info "Disabling other display managers"
for unit in gdm.service sddm.service ly.service; do
    if systemctl is-enabled --quiet "$unit" 2>/dev/null; then
        sudo systemctl disable --now "$unit" || true
        log::ok "Disabled $unit"
    fi
done

stow_system greetd

sudo systemctl enable greetd.service

log::ok "greetd enabled — edit greetd/etc/greetd/config.toml to tweak"
