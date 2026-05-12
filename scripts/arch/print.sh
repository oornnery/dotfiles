#!/usr/bin/env bash
# arch/print.sh — CUPS + filters + system-config-printer.
[[ -z "${ARCH_LIB_LOADED:-}" ]] && source "${BASH_SOURCE%/*}/lib.sh"

print::run() {
  log::step "Installing CUPS printing stack."
  pacman_install cups cups-filters system-config-printer
  run systemctl enable cups.service
  run systemctl enable cups.socket
  SERVICES_ENABLED+=(cups)
  PROMPTS_APPLIED+=("CUPS printing")
}
