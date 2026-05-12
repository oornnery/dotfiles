#!/usr/bin/env bash
# arch/keyring.sh — gnome-keyring + libsecret + PAM auto-unlock.
[[ -z "${ARCH_LIB_LOADED:-}" ]] && source "${BASH_SOURCE%/*}/lib.sh"

keyring::_patch_pam() {
  local file="$1"
  [[ -f "$file" ]] || return 0
  grep -q "pam_gnome_keyring.so" "$file" && return 0

  snapshot "$file"

  if [[ $DRY_RUN -eq 1 ]]; then
    printf '%s[dry-run]%s patch %s with pam_gnome_keyring\n' "$C_YEL" "$C_RST" "$file"
    return 0
  fi

  # Insert "auth optional pam_gnome_keyring.so" before pam_unix.so if present,
  # and "session optional pam_gnome_keyring.so auto_start" after session block.
  if grep -q '^auth.*pam_unix.so' "$file"; then
    sed -i '/^auth.*pam_unix.so/i auth       optional     pam_gnome_keyring.so' "$file"
  else
    echo 'auth       optional     pam_gnome_keyring.so' >> "$file"
  fi
  if grep -q '^session.*pam_unix.so' "$file"; then
    sed -i '/^session.*pam_unix.so/a session    optional     pam_gnome_keyring.so auto_start' "$file"
  else
    echo 'session    optional     pam_gnome_keyring.so auto_start' >> "$file"
  fi
  log::info "Patched $file with pam_gnome_keyring."
}

keyring::run() {
  log::step "Installing gnome-keyring + libsecret."
  pacman_install gnome-keyring libsecret seahorse

  # PAM integration: login + passwd. (Display managers like gdm wire it themselves.)
  keyring::_patch_pam /etc/pam.d/login
  keyring::_patch_pam /etc/pam.d/passwd

  log::info "gnome-keyring installed. SSH/secrets auto-unlock on login."
  log::info "Export SSH_AUTH_SOCK=\$XDG_RUNTIME_DIR/keyring/ssh in your shell rc if you want gnome-keyring as the SSH agent."
  PROMPTS_APPLIED+=("gnome-keyring + PAM")
}
