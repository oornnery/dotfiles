#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

require_root

log::banner "Apps" "Flatpak + Flathub"

log::info "Installing Flatpak"
sudo pacman -S --needed --noconfirm flatpak

log::info "Adding Flathub remote"
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

log::ok "Flatpak ready"
