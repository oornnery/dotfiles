#!/usr/bin/env bash
# arch/power.sh — Power management. Mutually exclusive: TLP | auto-cpufreq | power-profiles-daemon.
# shellcheck disable=SC2034  # REBOOT_NEEDED, USE_PPD are read by arch.sh
[[ -z "${ARCH_LIB_LOADED:-}" ]] && source "${BASH_SOURCE%/*}/lib.sh"

power::ppd() {
  log::info "Using power-profiles-daemon (default)."
  pacman_install power-profiles-daemon
  USE_PPD=1
}

power::tlp() {
  log::info "Installing TLP (replaces power-profiles-daemon)."
  pacman_install tlp tlp-rdw
  run systemctl enable tlp.service
  run systemctl mask systemd-rfkill.service systemd-rfkill.socket || true
  USE_PPD=0
  SERVICES_ENABLED+=(tlp)
  log::info "Tune /etc/tlp.conf (CPU_SCALING_GOVERNOR_*, *_CHARGE_THRESH_BAT0)."
}

power::auto_cpufreq() {
  log::info "Installing auto-cpufreq (replaces power-profiles-daemon)."
  pacman_install auto-cpufreq
  run systemctl enable auto-cpufreq.service
  USE_PPD=0
  SERVICES_ENABLED+=(auto-cpufreq)
}

power::amd_kernel_params() {
  [[ "${CPU_VENDOR:-}" == "amd" ]] || return 0
  log::info "Applying AMD power kernel params (amd_pstate=active, mem_sleep_default=s2idle)."
  patch_boot_param "amd_pstate=active mem_sleep_default=s2idle" "amd_pstate"
  REBOOT_NEEDED=1
  PROMPTS_APPLIED+=("amd_pstate kernel params")
}
