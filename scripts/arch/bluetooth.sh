#!/usr/bin/env bash
# arch/bluetooth.sh — bluez + blueman + Experimental flag (battery report).
[[ -z "${ARCH_LIB_LOADED:-}" ]] && source "${BASH_SOURCE%/*}/lib.sh"

bluetooth::run() {
  log::step "Installing Bluetooth stack."
  pacman_install bluez bluez-utils blueman

  if [[ ${IS_VM:-0} -eq 0 ]] && [[ -f /etc/bluetooth/main.conf ]] \
     && ! grep -q '^Experimental = true' /etc/bluetooth/main.conf; then
    log::info "Enabling bluetooth Experimental (headphone battery report)."
    snapshot /etc/bluetooth/main.conf
    run sed -i 's/^#\?\s*Experimental.*$/Experimental = true/' /etc/bluetooth/main.conf
  fi
}
