#!/usr/bin/env bash
# arch/wsl.sh — WSL-specific config (/etc/wsl.conf).
# Locale + timezone are handled by arch/locale.sh (runs everywhere).
[[ -z "${ARCH_LIB_LOADED:-}" ]] && source "${BASH_SOURCE%/*}/lib.sh"

wsl::run() {
  [[ ${IS_WSL:-0} -eq 1 ]] || return 0
  log::step "Applying WSL setup (/etc/wsl.conf)."
  install_template "wsl/etc/wsl.conf" "/etc/wsl.conf" "s/__USER__/$USER_NAME/"
  echo
  log::info "WSL setup applied. From PowerShell:"
  log::info "  wsl --shutdown"
  log::info "Then reopen Arch."
  PROMPTS_APPLIED+=("WSL setup")
}
