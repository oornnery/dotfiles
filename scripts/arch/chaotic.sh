#!/usr/bin/env bash
# arch/chaotic.sh — Chaotic-AUR repo (precompiled AUR packages).
[[ -z "${ARCH_LIB_LOADED:-}" ]] && source "${BASH_SOURCE%/*}/lib.sh"

chaotic::run() {
  log::step "Adding Chaotic-AUR repo."
  if grep -q '^\[chaotic-aur\]' /etc/pacman.conf 2>/dev/null; then
    log::info "Chaotic-AUR already configured."
    return 0
  fi
  if [[ $DRY_RUN -eq 1 ]]; then
    printf '%s[dry-run]%s add chaotic-aur key + keyring + mirrorlist + pacman.conf entry\n' "$C_YEL" "$C_RST"
    return 0
  fi
  pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
  pacman-key --lsign-key 3056513887B78AEB
  pacman -U --noconfirm \
    'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' \
    'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
  snapshot /etc/pacman.conf
  cat >> /etc/pacman.conf <<'EOF'

[chaotic-aur]
Include = /etc/pacman.d/chaotic-mirrorlist
EOF
  pacman -Sy
  PROMPTS_APPLIED+=("Chaotic-AUR repo")
}
