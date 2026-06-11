#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

require_root

log::banner "System" "Core services"

log::info "Enabling NetworkManager"
sudo systemctl enable NetworkManager.service

log::info "Enabling Bluetooth"
sudo systemctl enable bluetooth.service

log::info "Enabling time sync"
sudo systemctl enable systemd-timesyncd.service

log::info "Enabling DNS resolver"
sudo systemctl enable systemd-resolved.service
sudo ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf

if pacman -Qq power-profiles-daemon >/dev/null 2>&1; then
    log::info "Enabling power-profiles-daemon"
    sudo systemctl enable power-profiles-daemon.service
else
    log::skip "power-profiles-daemon not installed"
fi

log::info "Enabling paccache timer"
sudo systemctl enable paccache.timer

log::info "Enabling pkgfile-update timer"
sudo systemctl enable pkgfile-update.timer

log::step "Installing earlyoom (OOM prevention)"
sudo pacman -S --needed --noconfirm earlyoom
sudo systemctl enable earlyoom.service
log::ok "earlyoom enabled"

log::step "Tuning journald"

if [[ -f /etc/systemd/journald.conf ]]; then
    if grep -q '^SystemMaxUse=200M' /etc/systemd/journald.conf; then
        log::skip "journald SystemMaxUse already 200M"
    else
        snapshot /etc/systemd/journald.conf
        sudo sed -i 's/^#\?\s*SystemMaxUse=.*/SystemMaxUse=200M/' /etc/systemd/journald.conf
        log::ok "journald SystemMaxUse set to 200M"
    fi
fi

log::ok "Core services configured"
