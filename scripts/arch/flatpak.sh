#!/usr/bin/env bash
# arch/flatpak.sh — Flatpak + Flathub remote.
[[ -z "${ARCH_LIB_LOADED:-}" ]] && source "${BASH_SOURCE%/*}/lib.sh"

flatpak::run() {
  log::step "Installing Flatpak + Flathub."
  pacman_install flatpak
  run flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
  PROMPTS_APPLIED+=("Flatpak")
}
