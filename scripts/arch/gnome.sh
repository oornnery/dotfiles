#!/usr/bin/env bash
# arch/gnome.sh — GNOME desktop. Coexists with Hyprland; DM picks session at login.
[[ -z "${ARCH_LIB_LOADED:-}" ]] && source "${BASH_SOURCE%/*}/lib.sh"

gnome::run() {
  log::step "Installing GNOME desktop."
  pacman_install \
    gnome gnome-tweaks gnome-shell-extensions gnome-software \
    xdg-desktop-portal-gnome \
    gst-plugin-pipewire
  PROMPTS_APPLIED+=("GNOME desktop")
}
