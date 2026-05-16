#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../lib/detect.sh"

require_root
detect::system

log::banner "Desktop" "GNOME"

if [[ $IS_WSL -eq 1 ]]; then
    log::skip "WSL: use Windows desktop or WSLg"
    exit 0
fi

log::info "Installing GNOME"
sudo pacman -S --needed --noconfirm \
    gnome-shell gnome-control-center gnome-session gnome-settings-daemon \
    gnome-terminal nautilus gnome-text-editor gnome-calculator \
    gnome-disk-utility gnome-system-monitor \
    gnome-tweaks gnome-shell-extensions gnome-software \
    xdg-desktop-portal xdg-desktop-portal-gnome \
    gst-plugin-pipewire

log::ok "GNOME installed"
