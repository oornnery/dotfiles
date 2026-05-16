#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../lib/detect.sh"

USER_NAME="${USER_NAME:-${SUDO_USER:-$USER}}"

require_root
detect::system

log::banner "Hardware" "VM guest tools ($VM_TYPE)"

if [[ $IS_VM -eq 0 ]]; then
    log::skip "Not running in a VM"
    exit 0
fi

case "$VM_TYPE" in
    qemu|kvm)
        log::info "Installing QEMU/KVM guest tools"
        sudo pacman -S --needed --noconfirm \
            mesa qemu-guest-agent spice-vdagent xf86-video-qxl
        sudo systemctl enable qemu-guest-agent.service spice-vdagent.service
        ;;
    oracle)
        log::info "Installing VirtualBox guest tools"
        sudo pacman -S --needed --noconfirm virtualbox-guest-utils
        sudo systemctl enable vboxservice.service
        if id "$USER_NAME" >/dev/null 2>&1; then
            sudo gpasswd -a "$USER_NAME" vboxsf || true
        fi
        ;;
    vmware)
        log::info "Installing VMware guest tools"
        sudo pacman -S --needed --noconfirm open-vm-tools xf86-video-vmware
        sudo systemctl enable vmtoolsd.service vmware-vmblock-fuse.service
        ;;
    microsoft)
        log::info "Installing Hyper-V guest tools"
        sudo pacman -S --needed --noconfirm hyperv
        sudo systemctl enable \
            hv_fcopy_daemon.service hv_kvp_daemon.service hv_vss_daemon.service
        ;;
    *)
        log::warn "VM type '$VM_TYPE' has no known guest-tools package"
        ;;
esac

log::ok "VM guest tools configured"
