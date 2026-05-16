#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../lib/detect.sh"

NVIDIA_PROPRIETARY="${NVIDIA_PROPRIETARY:-0}"

require_root
detect::system

log::banner "Hardware" "NVIDIA GPU stack"

if [[ $IS_WSL -eq 1 || $IS_VM -eq 1 ]]; then
    log::skip "WSL/VM: skipping NVIDIA GPU stack"
    exit 0
fi

if [[ " ${GPU_VENDORS[*]} " != *" nvidia "* ]]; then
    log::warn "No NVIDIA GPU detected; skipping"
    exit 0
fi

MULTILIB=0
grep -q '^\[multilib\]' /etc/pacman.conf && MULTILIB=1

log::info "Installing Nouveau (FOSS) + vulkan-nouveau baseline"
sudo pacman -S --needed --noconfirm \
    mesa vulkan-icd-loader xf86-video-nouveau vulkan-nouveau nvtop

if [[ $MULTILIB -eq 1 ]]; then
    sudo pacman -S --needed --noconfirm lib32-mesa lib32-vulkan-icd-loader
fi

if [[ $NVIDIA_PROPRIETARY -eq 1 ]]; then
    log::info "Installing nvidia-open proprietary drivers"
    log::warn "If using linux-zen/linux-lts, switch to nvidia-open-dkms"
    sudo pacman -S --needed --noconfirm \
        nvidia-open nvidia-utils nvidia-settings libva-nvidia-driver

    if [[ $MULTILIB -eq 1 ]]; then
        sudo pacman -S --needed --noconfirm lib32-nvidia-utils
    fi

    log::warn "If 'nvidia-open' fails on older Maxwell/Pascal cards, retry with 'nvidia'"
    log::warn "REBOOT required for NVIDIA drivers"
fi

log::ok "NVIDIA GPU stack installed"
