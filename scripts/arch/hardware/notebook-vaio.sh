#!/usr/bin/env bash



source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../lib/detect.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../lib/bootloader.sh"

require_root
detect::system

log::banner "Hardware" "Notebook setup"

if [[ "$IS_WSL" -eq 1 || "$IS_VM" -eq 1 ]]; then
    log::skip "WSL/VM: skipping notebook-specific setup."
    exit 0
fi

if [[ "$IS_LAPTOP" -ne 1 ]]; then
    log::warn "Machine was not detected as laptop."
fi

if [[ "$DMI_VENDOR" == *"VAIO"* ]]; then
    log::ok "VAIO notebook detected"
else
    log::warn "This profile is optimized for VAIO notebooks"
fi

PKGS=(
    brightnessctl
    upower
    fwupd
    v4l-utils
    libinput
    power-profiles-daemon
)

log::info "Installing notebook packages"
sudo pacman -S --needed --noconfirm "${PKGS[@]}"

log::info "Enabling services"
sudo systemctl enable --now power-profiles-daemon.service

if id "$USER_NAME" >/dev/null 2>&1; then
    gpasswd -a "$USER_NAME" input || true
    gpasswd -a "$USER_NAME" video || true
fi

log::info "Applying AMD notebook kernel parameters"

if [[ "$CPU_VENDOR" == "amd" ]]; then
    bootloader::append_kernel_param "amd_pstate=active"
    bootloader::append_kernel_param "mem_sleep_default=s2idle"
    log::ok "AMD notebook kernel parameters applied"
fi

log::ok "Notebook setup completed"
