#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../lib/detect.sh"

require_root
detect::system

log::banner "Hardware" "AMD GPU stack"

if [[ $IS_WSL -eq 1 || $IS_VM -eq 1 ]]; then
    log::skip "WSL/VM: skipping AMD GPU stack"
    exit 0
fi

if [[ " ${GPU_VENDORS[*]} " != *" amd "* ]]; then
    log::warn "No AMD GPU detected; skipping"
    exit 0
fi

MULTILIB=0
grep -q '^\[multilib\]' /etc/pacman.conf && MULTILIB=1

PKGS=(
    mesa mesa-utils
    vulkan-icd-loader vulkan-radeon
    libva-utils vdpauinfo
    libva-mesa-driver libvdpau-va-gl
    xf86-video-amdgpu xf86-video-ati
    radeontop nvtop
    corectrl
)

if [[ $MULTILIB -eq 1 ]]; then
    PKGS+=(lib32-mesa lib32-vulkan-icd-loader lib32-vulkan-radeon)
fi

log::info "Installing AMD GPU packages"
sudo pacman -S --needed --noconfirm "${PKGS[@]}"

log::ok "AMD GPU stack installed"
