#!/usr/bin/env bash
# arch/services.sh — Enable core systemd services + timers + earlyoom + journald tuning.
[[ -z "${ARCH_LIB_LOADED:-}" ]] && source "${BASH_SOURCE%/*}/lib.sh"

services::core() {
  log::step "Enabling core services."
  run systemctl enable NetworkManager.service
  run systemctl enable bluetooth.service
  run systemctl enable systemd-timesyncd.service
  run systemctl enable systemd-resolved.service
  if [[ $DRY_RUN -eq 0 ]]; then
    ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf || true
  fi
  SERVICES_ENABLED+=(NetworkManager bluetooth systemd-timesyncd systemd-resolved)

  if [[ ${USE_PPD:-1} -eq 1 ]]; then
    run systemctl enable power-profiles-daemon.service
    SERVICES_ENABLED+=(power-profiles-daemon)
  else
    log::info "Skipping power-profiles-daemon (TLP or auto-cpufreq selected)."
  fi

  run systemctl enable paccache.timer
  run systemctl enable pkgfile-update.timer
  SERVICES_ENABLED+=(paccache.timer pkgfile-update.timer)
}

services::earlyoom() {
  log::info "Installing earlyoom (OOM prevention)."
  pacman_install earlyoom
  run systemctl enable earlyoom.service
  SERVICES_ENABLED+=(earlyoom)
}

services::journald_tune() {
  [[ -f /etc/systemd/journald.conf ]] || return 0
  [[ $DRY_RUN -eq 1 ]] && return 0
  grep -q '^SystemMaxUse=200M' /etc/systemd/journald.conf && return 0
  snapshot /etc/systemd/journald.conf
  sed -i 's/^#\?\s*SystemMaxUse=.*/SystemMaxUse=200M/' /etc/systemd/journald.conf
}

services::run() {
  services::core
  services::earlyoom
  services::journald_tune
}
