#!/usr/bin/env bash
# dev/stow.sh — stow all relevant dotfiles packages in one shot.
#
# Per-tool modules (dev/{bash,tmux,vim,nvim,alacritty,git,zsh}.sh) stow
# their own packages too. This script is the catch-all for everything
# that doesn't have a dedicated module (or when you just want one go).

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../lib/detect.sh"

USER_NAME="${USER_NAME:-${SUDO_USER:-$USER}}"
NVIM_DISTRO="${NVIM_DISTRO:-mini}"

require_root
detect::system

log::banner "Dev" "Stow all dotfiles"

if ! id "$USER_NAME" >/dev/null 2>&1; then
    die "User $USER_NAME doesn't exist"
fi

if ! command -v stow >/dev/null 2>&1; then
    log::info "Installing stow"
    sudo pacman -S --needed --noconfirm stow
fi

# Packages to stow. Order doesn't matter; stow_safe is idempotent.
packages=(
    bash zsh tmux vim
    git editor fabric
    alacritty
    bin
    hyprland waybar wofi walker mako
    astal
)

# Neovim: mini.nvim or LazyVim — mutually exclusive.
case "$NVIM_DISTRO" in
    lazy|lazyvim) packages+=(nvim-lazy) ;;
    mini|*)       packages+=(nvim) ;;
esac

[[ $IS_WSL -eq 1 ]] && packages+=(wsl)

for pkg in "${packages[@]}"; do
    stow_safe "$pkg" || log::warn "Stow failed for: $pkg"
done

# Apply active theme on top (writes ~/.config/<app>/theme.* files).
if [[ -n "${THEME:-}" ]] && command -v theme >/dev/null 2>&1; then
    if [[ $EUID -eq 0 && "$USER_NAME" != "root" ]]; then
        sudo -u "$USER_NAME" -H theme set "$THEME" || log::warn "theme set failed"
    else
        theme set "$THEME" || log::warn "theme set failed"
    fi
fi

log::ok "Stow completed"
