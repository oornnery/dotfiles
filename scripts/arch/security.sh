#!/usr/bin/env bash
# arch/security.sh — AppArmor, usbguard.
# shellcheck disable=SC2034  # REBOOT_NEEDED is read by arch.sh
[[ -z "${ARCH_LIB_LOADED:-}" ]] && source "${BASH_SOURCE%/*}/lib.sh"

security::apparmor() {
  log::info "Installing AppArmor."
  pacman_install apparmor
  run systemctl enable apparmor.service
  SERVICES_ENABLED+=(apparmor)
  log::warn "AppArmor requires kernel param: lsm=landlock,lockdown,yama,integrity,apparmor,bpf"
  log::warn "Add it to the bootloader cmdline manually (not auto-patched to avoid breakage)."
  REBOOT_NEEDED=1
  PROMPTS_APPLIED+=("AppArmor")
}

security::usbguard() {
  log::info "Installing usbguard."
  pacman_install usbguard
  run systemctl enable usbguard.service
  SERVICES_ENABLED+=(usbguard)
  log::warn "Generate initial policy after reboot: usbguard generate-policy > /etc/usbguard/rules.conf"
  PROMPTS_APPLIED+=("usbguard")
}
