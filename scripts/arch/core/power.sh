#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../lib/detect.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../lib/bootloader.sh"

POWER_BACKEND="${POWER_BACKEND:-ppd}"  # ppd | tlp | auto-cpufreq

require_root
detect::system

log::banner "Hardware" "Power management ($POWER_BACKEND)"

if [[ $IS_WSL -eq 1 || $IS_VM -eq 1 ]]; then
    log::skip "WSL/VM: skipping power management"
    exit 0
fi

case "$POWER_BACKEND" in
    ppd)
        log::info "Installing power-profiles-daemon"
        sudo pacman -S --needed --noconfirm power-profiles-daemon
        sudo systemctl enable --now power-profiles-daemon.service
        ;;
    tlp)
        log::info "Installing TLP"
        sudo pacman -S --needed --noconfirm tlp tlp-rdw
        sudo systemctl enable tlp.service
        sudo systemctl mask systemd-rfkill.service systemd-rfkill.socket || true
        log::info "Tune /etc/tlp.conf (CPU_SCALING_GOVERNOR_*, *_CHARGE_THRESH_BAT0)"
        ;;
    auto-cpufreq)
        log::info "Installing auto-cpufreq"
        sudo pacman -S --needed --noconfirm auto-cpufreq
        sudo systemctl enable auto-cpufreq.service
        ;;
    *)
        die "Unknown POWER_BACKEND: $POWER_BACKEND (use ppd|tlp|auto-cpufreq)"
        ;;
esac

if [[ "$CPU_VENDOR" == "amd" ]]; then
    log::info "Applying AMD power kernel params"
    bootloader::append_kernel_param "amd_pstate=active"
    bootloader::append_kernel_param "mem_sleep_default=s2idle"
    log::warn "REBOOT required for kernel params"
fi

log::ok "Power management configured"
