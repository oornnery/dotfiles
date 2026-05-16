#!/usr/bin/env bash
# dev/alacritty.sh — alacritty terminal + stow ~/dotfiles/alacritty.
#
# Optionally also installs ghostty as a secondary terminal (set
# WITH_GHOSTTY=0 in arch.conf to skip).

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../lib/detect.sh"

USER_NAME="${USER_NAME:-${SUDO_USER:-$USER}}"
WITH_GHOSTTY="${WITH_GHOSTTY:-1}"

require_root
detect::system

log::banner "Dev" "Alacritty"

if [[ $IS_WSL -eq 1 ]]; then
    log::skip "WSL: native terminal is the Windows host"
    exit 0
fi

PKGS=(alacritty)
[[ $WITH_GHOSTTY -eq 1 ]] && PKGS+=(ghostty)

log::info "Installing ${PKGS[*]}"
sudo pacman -S --needed --noconfirm "${PKGS[@]}"

stow_safe alacritty

# Seed the active theme into ~/.config/alacritty/theme.toml so
# alacritty.toml's `general.import = […]` resolves on first launch.
if [[ -n "${THEME:-}" ]] && command -v theme >/dev/null 2>&1; then
    if [[ $EUID -eq 0 && "$USER_NAME" != "root" ]]; then
        sudo -u "$USER_NAME" -H theme set "$THEME" || log::warn "theme set failed"
    else
        theme set "$THEME" || log::warn "theme set failed"
    fi
fi

log::ok "Alacritty setup completed"
