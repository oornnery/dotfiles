#!/usr/bin/env bash
# arch/luks.sh — Migrate mkinitcpio to systemd-cryptsetup (sd-encrypt) for TUI LUKS prompt.
# Requires has_luks_root to have set LUKS_ROOT_UUID + LUKS_ROOT_NAME.
# shellcheck disable=SC2034  # REBOOT_NEEDED is read by arch.sh
[[ -z "${ARCH_LIB_LOADED:-}" ]] && source "${BASH_SOURCE%/*}/lib.sh"

luks::_hooks_already_systemd() {
  grep -E '^HOOKS=.*systemd' /etc/mkinitcpio.conf >/dev/null 2>&1 \
    && grep -E '^HOOKS=.*sd-encrypt' /etc/mkinitcpio.conf >/dev/null 2>&1
}

luks::patch_mkinitcpio() {
  if luks::_hooks_already_systemd; then
    log::info "mkinitcpio.conf already uses systemd hooks; skipping."
    return 0
  fi
  log::info "Migrating mkinitcpio.conf to systemd hooks (sd-encrypt + sd-vconsole)."
  snapshot /etc/mkinitcpio.conf
  if [[ $DRY_RUN -eq 0 ]]; then
    # Replace the HOOKS=(...) line entirely.
    sed -i -E 's|^HOOKS=.*|HOOKS=(base systemd autodetect microcode modconf kms sd-vconsole block sd-encrypt filesystems fsck)|' \
      /etc/mkinitcpio.conf
  else
    printf '%s[dry-run]%s rewrite HOOKS= in /etc/mkinitcpio.conf\n' "$C_YEL" "$C_RST"
  fi
}

luks::regen_initramfs() {
  log::info "Regenerating initramfs (mkinitcpio -P)."
  run mkinitcpio -P
}

luks::patch_cmdline() {
  if [[ -z "${LUKS_ROOT_UUID:-}" ]] || [[ -z "${LUKS_ROOT_NAME:-}" ]]; then
    log::warn "LUKS_ROOT_UUID/LUKS_ROOT_NAME not set; skipping cmdline patch."
    return 0
  fi
  log::info "Patching bootloader cmdline: cryptdevice= → rd.luks.name=${LUKS_ROOT_UUID}=${LUKS_ROOT_NAME}"
  migrate_boot_cryptdevice "$LUKS_ROOT_UUID" "$LUKS_ROOT_NAME"
}

luks::sanity_check() {
  [[ $DRY_RUN -eq 1 ]] && return 0
  local img=/boot/initramfs-linux.img
  [[ -f "$img" ]] || { log::warn "$img not found; skipping sanity check."; return 0; }
  if command -v lsinitcpio >/dev/null 2>&1 \
     && ! lsinitcpio "$img" 2>/dev/null | grep -q 'usr/lib/systemd/systemd-cryptsetup'; then
    log::err "systemd-cryptsetup not in initramfs. Restoring mkinitcpio.conf from backup and aborting."
    local bak="$BACKUP_DIR/etc/mkinitcpio.conf"
    [[ -f "$bak" ]] && cp -a "$bak" /etc/mkinitcpio.conf
    run mkinitcpio -P || true
    return 1
  fi
  log::info "Sanity check passed: systemd-cryptsetup present in initramfs."
}

luks::run() {
  log::step "Configuring LUKS TUI prompt (systemd-cryptsetup)."

  if ! has_luks_root; then
    log::info "No LUKS root detected; skipping."
    return 0
  fi
  log::info "LUKS root: /dev/mapper/$LUKS_ROOT_NAME (UUID=$LUKS_ROOT_UUID)"

  pacman_install cryptsetup

  luks::patch_mkinitcpio
  luks::patch_cmdline
  luks::regen_initramfs

  if ! luks::sanity_check; then
    log::err "LUKS migration aborted. Reboot is NOT safe — restore manually if needed."
    return 1
  fi

  REBOOT_NEEDED=1
  PROMPTS_APPLIED+=("LUKS systemd-cryptsetup TUI")
  log::warn "REBOOT required to use the new TUI LUKS prompt."
}
