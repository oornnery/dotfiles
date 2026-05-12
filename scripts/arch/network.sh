#!/usr/bin/env bash
# arch/network.sh — NetworkManager + network-manager-applet + optional iwd backend.
[[ -z "${ARCH_LIB_LOADED:-}" ]] && source "${BASH_SOURCE%/*}/lib.sh"

network::base() {
  log::step "Installing NetworkManager."
  pacman_install \
    networkmanager network-manager-applet \
    brightnessctl
}

network::iwd_backend() {
  log::info "Switching NetworkManager wifi backend to iwd."
  pacman_install iwd
  install_template "system/etc/NetworkManager/conf.d/wifi_backend.conf" \
    "/etc/NetworkManager/conf.d/wifi_backend.conf"
  PROMPTS_APPLIED+=("NetworkManager iwd backend")
}

network::run() {
  network::base
}
