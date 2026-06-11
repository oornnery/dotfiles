#!/usr/bin/env bash
# core/fingerprint.sh — fprintd + PAM integration.
#
# Idempotent. Patches PAM files to make sudo/login/polkit accept fingerprint.
# After install, enroll a finger with:   fprintd-enroll
# To remove, delete the inserted lines from /etc/pam.d/{sudo,login,polkit-1}.

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../lib/detect.sh"

ENABLE_FINGERPRINT="${ENABLE_FINGERPRINT:-0}"

require_root
detect::system

log::banner "Core" "Fingerprint reader (fprintd + PAM)"

if [[ "$ENABLE_FINGERPRINT" != "1" ]]; then
    log::skip "ENABLE_FINGERPRINT=0 — set it to 1 in arch.conf to install"
    exit 0
fi

if [[ $IS_WSL -eq 1 || $IS_VM -eq 1 ]]; then
    log::skip "WSL/VM: no fingerprint hardware"
    exit 0
fi

log::info "Installing fprintd + libfprint"
sudo pacman -S --needed --noconfirm fprintd libfprint

_patch_pam() {
    local file="$1"
    [[ -f "$file" ]] || { log::warn "$file not found — skipping"; return 0; }

    if grep -q "pam_fprintd.so" "$file"; then
        log::skip "$file already patched"
        return 0
    fi

    snapshot "$file"
    # Insert `auth sufficient pam_fprintd.so` BEFORE the first auth line so
    # it short-circuits a successful fingerprint scan past pam_unix.
    sudo sed -i '0,/^auth/{s//auth      sufficient  pam_fprintd.so\n&/}' "$file"
    log::ok "Patched $file"
}

log::step "Patching PAM files"
_patch_pam /etc/pam.d/sudo
_patch_pam /etc/pam.d/login
_patch_pam /etc/pam.d/polkit-1

log::ok "fprintd installed and PAM patched"
log::warn "Enroll a finger with: fprintd-enroll"
log::warn "Verify with: fprintd-verify"
