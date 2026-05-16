#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

require_root

log::banner "System" "gnome-keyring + libsecret + PAM"

log::info "Installing gnome-keyring stack"
sudo pacman -S --needed --noconfirm \
    gnome-keyring libsecret seahorse polkit-gnome

keyring::_patch_pam() {
    local file="$1"
    [[ -f "$file" ]] || return 0

    if grep -q "pam_gnome_keyring.so" "$file"; then
        log::skip "$file already patched"
        return 0
    fi

    snapshot "$file"

    if grep -q '^auth.*pam_unix.so' "$file"; then
        sudo sed -i '/^auth.*pam_unix.so/i auth       optional     pam_gnome_keyring.so' "$file"
    else
        echo 'auth       optional     pam_gnome_keyring.so' | sudo tee -a "$file" >/dev/null
    fi

    if grep -q '^session.*pam_unix.so' "$file"; then
        sudo sed -i '/^session.*pam_unix.so/a session    optional     pam_gnome_keyring.so auto_start' "$file"
    else
        echo 'session    optional     pam_gnome_keyring.so auto_start' | sudo tee -a "$file" >/dev/null
    fi

    log::ok "Patched $file"
}

log::step "Patching PAM files"
keyring::_patch_pam /etc/pam.d/login
keyring::_patch_pam /etc/pam.d/gdm-password

if ! grep -qxF 'password optional pam_gnome_keyring.so' /etc/pam.d/passwd; then
    snapshot /etc/pam.d/passwd
    echo 'password optional pam_gnome_keyring.so' | sudo tee -a /etc/pam.d/passwd >/dev/null
    log::ok "Patched /etc/pam.d/passwd"
else
    log::skip "/etc/pam.d/passwd already patched"
fi

log::ok "gnome-keyring configured (SSH/secrets auto-unlock on login)"
