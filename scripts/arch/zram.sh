#!/usr/bin/env bash
# arch/zram.sh — zram swap (half of RAM, zstd).
[[ -z "${ARCH_LIB_LOADED:-}" ]] && source "${BASH_SOURCE%/*}/lib.sh"

zram::run() {
  if [[ ${IS_VM:-0} -eq 1 ]]; then
    log::info "Skipping zram in VM."
    return 0
  fi
  log::step "Configuring zram swap."
  pacman_install zram-generator
  install_template "system/etc/systemd/zram-generator.conf" \
    "/etc/systemd/zram-generator.conf"
  PROMPTS_APPLIED+=("zram swap")
}
