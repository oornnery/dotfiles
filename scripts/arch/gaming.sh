#!/usr/bin/env bash
# arch/gaming.sh — Steam, wine, gamemode, mangohud, lutris.
# Requires [multilib] enabled (preflight handles that).
[[ -z "${ARCH_LIB_LOADED:-}" ]] && source "${BASH_SOURCE%/*}/lib.sh"

gaming::run() {
  if ! multilib_enabled; then
    log::warn "[multilib] not enabled; gaming stack requires lib32-*. Skipping."
    return 0
  fi
  log::step "Installing gaming stack."
  pacman_install \
    steam lutris \
    wine wine-mono wine-gecko winetricks \
    gamemode lib32-gamemode \
    mangohud lib32-mangohud
  PROMPTS_APPLIED+=("gaming stack")
}
