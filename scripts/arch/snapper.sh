#!/usr/bin/env bash
# arch/snapper.sh — snapper + snap-pac (btrfs snapshots on pacman ops).
[[ -z "${ARCH_LIB_LOADED:-}" ]] && source "${BASH_SOURCE%/*}/lib.sh"

snapper::run() {
  local root_fs
  root_fs="$(findmnt -no FSTYPE / 2>/dev/null || true)"
  if [[ "$root_fs" != "btrfs" ]]; then
    log::warn "Root fs is '$root_fs', not btrfs — snapper skipped."
    return 0
  fi
  log::step "Installing snapper + snap-pac."
  pacman_install snapper snap-pac
  if [[ $DRY_RUN -eq 0 ]] && ! snapper -c root list >/dev/null 2>&1; then
    run snapper -c root create-config / \
      || log::warn "snapper config failed (existing subvolume?)."
  fi
  PROMPTS_APPLIED+=("snapper btrfs snapshots")
}
