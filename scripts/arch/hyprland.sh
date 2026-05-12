#!/usr/bin/env bash
# arch/hyprland.sh — Hyprland (Wayland tiling) + utilities.
[[ -z "${ARCH_LIB_LOADED:-}" ]] && source "${BASH_SOURCE%/*}/lib.sh"

hyprland::run() {
  log::step "Installing Hyprland desktop."
  pacman_install \
    hyprland hypridle hyprlock hyprshot hyprpaper hyprsunset \
    xdg-desktop-portal-hyprland xdg-desktop-portal-gtk \
    waybar swaync \
    wofi rofi-wayland \
    swww nwg-look kvantum \
    qt5-wayland qt6-wayland \
    hyprpolkitagent \
    grim slurp swappy wlogout \
    wl-clipboard cliphist
  PROMPTS_APPLIED+=("Hyprland desktop")
  log::info "Hyprland config will be linked via stow (~/.config/hypr/)."
}
