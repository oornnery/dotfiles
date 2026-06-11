#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../lib/detect.sh"

require_root
detect::system

log::banner "Core" "Hardware monitoring (sensors + SMART)"

if [[ $IS_WSL -eq 1 ]]; then
    log::skip "WSL: no real hardware to monitor"
    exit 0
fi

PKGS=(
    lm_sensors      # CPU/GPU/MB temps + fan speeds (sensors command)
    smartmontools   # disk health via S.M.A.R.T. (smartctl)
)

# NVMe-specific tooling — only useful if an NVMe is present.
if compgen -G "/dev/nvme*" >/dev/null; then
    PKGS+=(nvme-cli)
fi

log::info "Installing monitoring tools"
sudo pacman -S --needed --noconfirm "${PKGS[@]}"

if [[ $IS_VM -eq 0 ]]; then
    log::info "Enabling smartd.service (SMART daemon)"
    sudo systemctl enable smartd.service || log::warn "Could not enable smartd"

    log::info "Run 'sudo sensors-detect --auto' once to populate /etc/modules-load.d"
    log::info "Then 'sensors' shows temps. 'smartctl -a /dev/sda' shows disk health."
fi

log::ok "Monitoring tools installed"
