#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

ENABLE_APPARMOR="${ENABLE_APPARMOR:-1}"
ENABLE_USBGUARD="${ENABLE_USBGUARD:-0}"

require_root

log::banner "Security" "Hardening (AppArmor, usbguard)"

if [[ $ENABLE_APPARMOR -eq 1 ]]; then
    log::info "Installing AppArmor"
    sudo pacman -S --needed --noconfirm apparmor
    sudo systemctl enable apparmor.service
    log::warn "AppArmor requires kernel param: lsm=landlock,lockdown,yama,integrity,apparmor,bpf"
    log::warn "Add manually to bootloader cmdline (not auto-patched to avoid breakage)"
    log::warn "REBOOT required after adding kernel param"
else
    log::skip "AppArmor disabled (ENABLE_APPARMOR=0)"
fi

if [[ $ENABLE_USBGUARD -eq 1 ]]; then
    log::info "Installing usbguard"
    sudo pacman -S --needed --noconfirm usbguard
    sudo systemctl enable usbguard.service
    log::warn "Generate initial policy after reboot:"
    log::warn "  sudo usbguard generate-policy > /etc/usbguard/rules.conf"
else
    log::skip "usbguard disabled (ENABLE_USBGUARD=0)"
fi

log::ok "Hardening configured"
