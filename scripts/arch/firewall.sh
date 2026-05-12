#!/usr/bin/env bash
# arch/firewall.sh — ufw deny incoming / allow outgoing.
[[ -z "${ARCH_LIB_LOADED:-}" ]] && source "${BASH_SOURCE%/*}/lib.sh"

firewall::run() {
  log::step "Installing ufw firewall."
  pacman_install ufw
  run ufw default deny incoming
  run ufw default allow outgoing
  run ufw --force enable
  run systemctl enable ufw.service
  SERVICES_ENABLED+=(ufw)
  PROMPTS_APPLIED+=("ufw firewall")
}
