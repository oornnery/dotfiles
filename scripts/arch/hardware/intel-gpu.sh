#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../lib/detect.sh"

require_root
detect::system

log::banner "Hardware" "Intel GPU stack"

if [[ $IS_WSL -eq 1 || $IS_VM -eq 1 ]]; then
    log::skip "WSL/VM: skipping Intel GPU stack"
    exit 0
fi

if [[ " ${GPU_VENDORS[*]} " != *" intel "* ]]; then
    log::warn "No Intel GPU detected; skipping"
    exit 0
fi

MULTILIB=0
grep -q '^\[multilib\]' /etc/pacman.conf && MULTILIB=1

PKGS=(
    mesa
    vulkan-icd-loader vulkan-intel
    intel-media-driver libva-intel-driver
    intel-gpu-tools
    libva-utils vdpauinfo
)

if [[ $MULTILIB -eq 1 ]]; then
    PKGS+=(lib32-mesa lib32-vulkan-icd-loader lib32-vulkan-intel)
fi

log::info "Installing Intel GPU packages"
sudo pacman -S --needed --noconfirm "${PKGS[@]}"

log::ok "Intel GPU stack installed"
