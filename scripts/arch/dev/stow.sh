#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../lib/detect.sh"

USER_NAME="${USER_NAME:-${SUDO_USER:-$USER}}"

require_root
detect::system

log::banner "System" "Stow dotfiles"

if ! id "$USER_NAME" >/dev/null 2>&1; then
    log::warn "User $USER_NAME doesn't exist; skipping stow"
    exit 0
fi

if ! command -v stow >/dev/null 2>&1; then
    log::info "Installing stow"
    sudo pacman -S --needed --noconfirm stow
fi

user_home="$(getent passwd "$USER_NAME" | cut -d: -f6)"
dotfiles_dir="$user_home/dotfiles"

if [[ ! -d "$dotfiles_dir" ]]; then
    log::warn "$dotfiles_dir not found — clone the dotfiles repo there first"
    exit 0
fi

log::info "Stowing dotfiles from $dotfiles_dir"

packages=(bash zsh tmux nvim git editor fabric system)

pacman -Qq hyprland >/dev/null 2>&1 && packages+=(hyprland)
[[ $IS_WSL -eq 1 ]] && packages+=(wsl)

for pkg in "${packages[@]}"; do
    if [[ ! -d "$dotfiles_dir/$pkg" ]]; then
        log::skip "Package '$pkg' not in repo"
        continue
    fi
    log::info "Stowing '$pkg'"
    sudo -u "$USER_NAME" stow -d "$dotfiles_dir" -t "$user_home" -R "$pkg" \
        || log::warn "stow failed for '$pkg' (file conflict?)"
done

log::ok "Stow completed"
