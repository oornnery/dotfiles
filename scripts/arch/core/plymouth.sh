#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../lib/detect.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../lib/bootloader.sh"

require_root
detect::system

log::banner "System" "Plymouth boot splash"

if [[ $IS_WSL -eq 1 || $IS_VM -eq 1 ]]; then
    log::skip "WSL/VM: skipping plymouth"
    exit 0
fi

log::info "Installing plymouth"
sudo pacman -S --needed --noconfirm plymouth

log::step "Adding plymouth hook to mkinitcpio.conf"

if grep -qE '^HOOKS=.*\bplymouth\b' /etc/mkinitcpio.conf; then
    log::skip "plymouth hook already present in HOOKS="
else
    snapshot /etc/mkinitcpio.conf
    if grep -qE '^HOOKS=.*\bsystemd\b' /etc/mkinitcpio.conf; then
        sudo sed -i -E 's/^(HOOKS=.*)\bsystemd\b/\1systemd plymouth/' /etc/mkinitcpio.conf
    else
        sudo sed -i -E 's/^(HOOKS=.*)\bbase\b/\1base plymouth/' /etc/mkinitcpio.conf
    fi
    log::ok "plymouth hook added"
fi

log::step "Adding quiet splash to kernel cmdline"
bootloader::append_kernel_param "quiet"
bootloader::append_kernel_param "splash"

log::step "Regenerating initramfs"
sudo mkinitcpio -P

log::warn "REBOOT required to see splash. Pick a theme with: plymouth-set-default-theme -l"
log::ok "Plymouth configured"
