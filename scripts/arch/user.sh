#!/usr/bin/env bash
# arch/user.sh — User creation, wheel group, sudoers, linger, SSH key.
[[ -z "${ARCH_LIB_LOADED:-}" ]] && source "${BASH_SOURCE%/*}/lib.sh"

user::ensure() {
  log::step "User setup."
  if id "$USER_NAME" >/dev/null 2>&1; then
    local current_shell in_wheel
    current_shell="$(getent passwd "$USER_NAME" | cut -d: -f7)"
    if id -nG "$USER_NAME" | grep -qw wheel; then in_wheel=1; else in_wheel=0; fi
    log::info "User '$USER_NAME' exists. shell=$current_shell, wheel=$in_wheel."
    # Only ask if something would actually change.
    if [[ "$current_shell" != "$USER_SHELL" ]] || [[ $in_wheel -eq 0 ]]; then
      if ask "Ensure '$USER_NAME' is in wheel group and uses $USER_SHELL?"; then
        [[ $in_wheel -eq 0 ]] && run usermod -aG wheel "$USER_NAME"
        if [[ "$current_shell" != "$USER_SHELL" ]]; then
          run chsh -s "$USER_SHELL" "$USER_NAME" \
            || log::warn "chsh failed (shell not in /etc/shells yet?)."
        fi
      else
        log::info "Leaving '$USER_NAME' as-is."
      fi
    else
      log::ok "User '$USER_NAME' already correctly configured."
    fi
  else
    if ask "User '$USER_NAME' not found. Create it (wheel, shell=$USER_SHELL)?"; then
      run useradd -m -G wheel -s "$USER_SHELL" "$USER_NAME"
      if [[ $DRY_RUN -eq 0 ]] && [[ $UNATTENDED -eq 0 ]]; then
        echo "Set password for $USER_NAME:"
        passwd "$USER_NAME"
      fi
    else
      log::warn "Skipping user creation — many later steps will be no-ops without '$USER_NAME'."
    fi
  fi
}

user::sudoers_wheel() {
  if [[ -f /etc/sudoers.d/10-wheel ]]; then
    log::ok "Wheel sudoers already configured."
    return 0
  fi
  if ! ask "Grant wheel group sudo access (creates /etc/sudoers.d/10-wheel)?"; then
    log::info "Skipping wheel sudo grant."
    return 0
  fi
  log::info "Granting wheel sudo (validated via visudo)."
  if [[ $DRY_RUN -eq 1 ]]; then
    printf '%s[dry-run]%s install validated /etc/sudoers.d/10-wheel\n' "$C_YEL" "$C_RST"
    return 0
  fi
  local tmp
  tmp="$(mktemp)"
  printf '%%wheel ALL=(ALL:ALL) ALL\n' > "$tmp"
  if visudo -cf "$tmp" >/dev/null; then
    install -m 440 -o root -g root "$tmp" /etc/sudoers.d/10-wheel
    rm -f "$tmp"
  else
    rm -f "$tmp"
    log::err "visudo validation failed; aborting (no lockout)."
    exit 1
  fi
}

user::linger() {
  id "$USER_NAME" >/dev/null 2>&1 || return 0
  # Skip if already enabled — idempotent silent.
  if loginctl show-user "$USER_NAME" 2>/dev/null | grep -q '^Linger=yes'; then
    return 0
  fi
  if ask "Enable systemd linger for '$USER_NAME' (lets user services run without login)?"; then
    run loginctl enable-linger "$USER_NAME" 2>/dev/null \
      || log::warn "enable-linger failed (no systemd active yet?)."
  fi
}

user::ssh_key() {
  id "$USER_NAME" >/dev/null 2>&1 || return 0
  local user_home key
  user_home="$(getent passwd "$USER_NAME" | cut -d: -f6)"
  key="$user_home/.ssh/id_ed25519"
  [[ -f "$key" ]] && return 0
  log::info "Generating ed25519 SSH key for $USER_NAME."
  local ke=""
  if [[ $UNATTENDED -eq 0 ]] && [[ $DRY_RUN -eq 0 ]]; then
    read -rp "  email comment for key: " ke || true
  fi
  log::warn "ssh-keygen will prompt for a passphrase. Leave empty only if you understand the risk."
  run as_user mkdir -p "$user_home/.ssh"
  run as_user chmod 700 "$user_home/.ssh"
  run as_user ssh-keygen -t ed25519 -C "$ke" -f "$key"
  if [[ $DRY_RUN -eq 0 ]] && [[ -f "${key}.pub" ]]; then
    echo
    log::info "Public key (paste into GitHub/GitLab):"
    cat "${key}.pub"
    echo
  fi
}

user::run() {
  user::ensure
  user::sudoers_wheel
  user::linger
}
