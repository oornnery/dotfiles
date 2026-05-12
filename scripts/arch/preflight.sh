#!/usr/bin/env bash
# arch/preflight.sh — root check, pacman lock, network, disk, pacman.conf tweaks, reflector.
[[ -z "${ARCH_LIB_LOADED:-}" ]] && source "${BASH_SOURCE%/*}/lib.sh"

preflight::checks() {
  [[ $EUID -eq 0 ]] || { log::err "Run as root."; exit 1; }

  if [[ -f /var/lib/pacman/db.lck ]]; then
    log::err "pacman db locked (/var/lib/pacman/db.lck). Remove if no pacman process."
    exit 1
  fi

  if ! ping -c1 -W3 archlinux.org >/dev/null 2>&1; then
    log::err "No network (cannot reach archlinux.org)."
    exit 1
  fi

  local avail_kb
  avail_kb="$(df -k --output=avail / | tail -1 | tr -d ' ')"
  if [[ -n "$avail_kb" ]] && [[ "$avail_kb" -lt 5242880 ]]; then
    log::err "Less than 5GB free on /. Free up space first."
    exit 1
  fi
}

preflight::pacman_conf() {
  log::step "Configuring pacman.conf."
  snapshot /etc/pacman.conf
  run sed -i 's/^#\?Color/Color/' /etc/pacman.conf
  run sed -i 's/^#\?ParallelDownloads = .*/ParallelDownloads = 5/' /etc/pacman.conf
  grep -qxF 'ILoveCandy' /etc/pacman.conf \
    || run sed -i '/^Color/a ILoveCandy' /etc/pacman.conf

  if grep -q '^#\[multilib\]$' /etc/pacman.conf; then
    log::info "Enabling [multilib] header."
    run sed -i 's/^#\[multilib\]$/[multilib]/' /etc/pacman.conf
  fi
  if awk '/^\[multilib\]/{f=1;next} f&&/^#\s*Include/{print;exit}' /etc/pacman.conf \
     | grep -q .; then
    run sed -i '/^\[multilib\]/{n;s/^#\s*Include/Include/}' /etc/pacman.conf
  fi
}

preflight::update() {
  log::step "Updating system."
  run pacman -Syyu "${PAC_FLAGS[@]}"
}

preflight::reflector() {
  log::step "Refreshing mirrors."
  pacman_install reflector || { log::warn "reflector install failed; skipping."; return 0; }
  command -v reflector >/dev/null 2>&1 || return 0

  if [[ ! -f /etc/pacman.d/mirrorlist ]]; then
    log::warn "/etc/pacman.d/mirrorlist missing; running reflector to seed it."
    run reflector --country "$MIRROR_COUNTRY" --age 12 --protocol https \
      --sort rate --save /etc/pacman.d/mirrorlist \
      || log::warn "reflector run failed."
  elif find /etc/pacman.d/mirrorlist -mmin +720 2>/dev/null | grep -q .; then
    log::info "Mirrorlist >12h old; refreshing (country=$MIRROR_COUNTRY)."
    snapshot /etc/pacman.d/mirrorlist
    run reflector --country "$MIRROR_COUNTRY" --age 12 --protocol https \
      --sort rate --save /etc/pacman.d/mirrorlist \
      || log::warn "reflector run failed; keeping existing."
  else
    log::info "Mirrorlist fresh (<12h); skip refresh."
  fi
}

preflight::run() {
  preflight::checks
  preflight::pacman_conf
  if ask "Run full system upgrade now (pacman -Syyu — can be slow on first run)?"; then
    preflight::update
  else
    log::warn "Skipping system upgrade. Partial upgrades can break Arch — run 'pacman -Syyu' soon."
    # We still need to sync the package database to install anything later.
    run pacman -Sy "${PAC_FLAGS[@]}"
  fi
  if ask "Refresh mirrorlist via reflector (country=$MIRROR_COUNTRY)?"; then
    preflight::reflector
  fi
}
