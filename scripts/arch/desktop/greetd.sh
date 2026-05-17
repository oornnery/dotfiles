#!/usr/bin/env bash
# desktop/greetd.sh — greetd + tuigreet, configured via stow.
#
# Files (stowed to /):
#   greetd/etc/greetd/config.toml   greeter command + default session
#   greetd/etc/pam.d/greetd         PAM stack with pam_gnome_keyring
#                                   so the user's keyring unlocks at
#                                   login (Vivaldi/Chromium/SSH need it)
#
# Edit then: sudo systemctl restart greetd

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../lib/detect.sh"

require_root
detect::system

log::banner "Desktop" "greetd + tuigreet"

if [[ $IS_WSL -eq 1 || $IS_VM -eq 1 ]]; then
    log::skip "WSL/VM: no display manager needed"
    exit 0
fi

log::info "Installing greetd + tuigreet + gnome-keyring (PAM unlock)"
sudo pacman -S --needed --noconfirm greetd greetd-tuigreet gnome-keyring

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
