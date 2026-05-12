#!/usr/bin/env bash
# arch/aur.sh — paru (AUR helper) + opt-in AUR packages.
[[ -z "${ARCH_LIB_LOADED:-}" ]] && source "${BASH_SOURCE%/*}/lib.sh"

aur::install_paru() {
  id "$USER_NAME" >/dev/null 2>&1 || return 0
  command -v paru >/dev/null 2>&1 && { log::info "paru already installed."; return 0; }
  log::step "Building paru as $USER_NAME."
  if [[ $DRY_RUN -eq 1 ]]; then
    printf '%s[dry-run]%s clone+makepkg paru as %s\n' "$C_YEL" "$C_RST" "$USER_NAME"
    return 0
  fi
  sudo -u "$USER_NAME" -H bash -c '
    set -e
    cd /tmp
    rm -rf paru
    git clone https://aur.archlinux.org/paru.git
    cd paru
    makepkg -si --noconfirm
  ' || { log::warn "paru build failed."; return 1; }
  PROMPTS_APPLIED+=("paru AUR helper")
}

# aur::install_pkgs pkg1 pkg2 ...
aur::install_pkgs() {
  [[ $# -eq 0 ]] && return 0
  id "$USER_NAME" >/dev/null 2>&1 || return 0
  command -v paru >/dev/null 2>&1 || { log::warn "paru not installed; skipping AUR packages."; return 0; }
  log::step "Installing AUR packages: $*"
  if [[ $DRY_RUN -eq 1 ]]; then
    printf '%s[dry-run]%s paru -S --needed --noconfirm %s\n' "$C_YEL" "$C_RST" "$*"
    return 0
  fi
  sudo -u "$USER_NAME" -H paru -S --needed --noconfirm "$@" \
    || log::warn "paru install failed for: $*"
  PROMPTS_APPLIED+=("AUR pkgs: $*")
}

aur::run() {
  aur::install_paru || return 0
  # Default AUR package list. Orchestrator can override AUR_PKGS before sourcing.
  local -a pkgs=("${AUR_PKGS[@]:-pacsea-bin}")
  [[ ${#pkgs[@]} -gt 0 ]] && aur::install_pkgs "${pkgs[@]}"
}
