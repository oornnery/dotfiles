#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

USER_NAME="${USER_NAME:-${SUDO_USER:-$USER}}"
USER_SHELL="${USER_SHELL:-/bin/zsh}"

require_root

log::step "User setup: $USER_NAME"

if id "$USER_NAME" >/dev/null 2>&1; then
    current_shell="$(getent passwd "$USER_NAME" | cut -d: -f7)"
    in_wheel=0
    id -nG "$USER_NAME" | grep -qw wheel && in_wheel=1

    log::info "User '$USER_NAME' exists (shell=$current_shell, wheel=$in_wheel)"

    if [[ $in_wheel -eq 0 ]]; then
        log::info "Adding to wheel group"
        sudo usermod -aG wheel "$USER_NAME"
        log::ok "Added to wheel"
    else
        log::skip "Already in wheel group"
    fi

    if [[ "$current_shell" != "$USER_SHELL" ]]; then
        log::info "Changing shell to $USER_SHELL"
        sudo chsh -s "$USER_SHELL" "$USER_NAME" || log::warn "chsh failed (shell not in /etc/shells?)"
    else
        log::skip "Shell already $USER_SHELL"
    fi
else
    if ask::confirm "User '$USER_NAME' not found. Create it (wheel, shell=$USER_SHELL)?"; then
        sudo useradd -m -G wheel -s "$USER_SHELL" "$USER_NAME"
        log::ok "User '$USER_NAME' created"
        echo "Set password for $USER_NAME:"
        sudo passwd "$USER_NAME"
    else
        die "User creation skipped — aborting"
    fi
fi

log::step "Configuring wheel sudoers"

if [[ -f /etc/sudoers.d/10-wheel ]]; then
    log::skip "Wheel sudoers already configured"
else
    log::info "Granting wheel sudo (validated via visudo)"
    tmp="$(mktemp)"
    echo '%wheel ALL=(ALL:ALL) ALL' > "$tmp"
    if sudo visudo -cf "$tmp" >/dev/null; then
        sudo install -m 440 -o root -g root "$tmp" /etc/sudoers.d/10-wheel
        rm -f "$tmp"
        log::ok "Wheel sudoers installed"
    else
        rm -f "$tmp"
        die "visudo validation failed; aborting (no lockout)"
    fi
fi

log::step "Enabling systemd linger for $USER_NAME"

if loginctl show-user "$USER_NAME" 2>/dev/null | grep -q '^Linger=yes'; then
    log::skip "Linger already enabled"
else
    sudo loginctl enable-linger "$USER_NAME" || log::warn "enable-linger failed"
    log::ok "Linger enabled"
fi

log::step "Generating SSH key (ed25519)"

user_home="$(getent passwd "$USER_NAME" | cut -d: -f6)"
key="$user_home/.ssh/id_ed25519"

if [[ -f "$key" ]]; then
    log::skip "SSH key already exists: $key"
else
    read -rp "Email comment for SSH key: " ke || true
    sudo -u "$USER_NAME" mkdir -p "$user_home/.ssh"
    sudo -u "$USER_NAME" chmod 700 "$user_home/.ssh"
    sudo -u "$USER_NAME" ssh-keygen -t ed25519 -C "$ke" -f "$key"
    log::ok "SSH key generated: $key"
    echo
    log::info "Public key (paste into GitHub/GitLab):"
    cat "${key}.pub"
    echo
fi

log::ok "User setup completed"
