#!/usr/bin/env bash
# apps.sh — apps de produtividade comuns (video, image, PDF, calc, etc).
# Inspirado no que Omarchy curates além do basic Hyprland stack.

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../lib/detect.sh"

require_root
detect::system

log::banner "Dev" "Productivity apps"

if [[ $IS_WSL -eq 1 ]]; then
    log::skip "WSL: use Windows apps for GUI productivity"
    exit 0
fi

log::info "Installing productivity apps (official repos)"
sudo pacman -S --needed --noconfirm \
    mpv \
    imv \
    localsend \
    evince \
    gnome-calculator libqalculate \
    sushi \
    gpu-screen-recorder

USER_NAME="${USER_NAME:-${SUDO_USER:-$USER}}"

# AUR: obsidian (sometimes in extra, sometimes only AUR depending on release)
if sudo -u "$USER_NAME" -H bash -c 'command -v paru' >/dev/null 2>&1; then
    log::info "Installing obsidian (AUR if not in repos)"
    if ! sudo pacman -Si obsidian >/dev/null 2>&1; then
        sudo -u "$USER_NAME" -H paru -S --needed --noconfirm obsidian \
            || log::warn "obsidian failed — instale manualmente se necessário"
    else
        sudo pacman -S --needed --noconfirm obsidian
    fi
else
    log::warn "paru não instalado — skip obsidian"
fi

log::ok "Productivity apps installed"
