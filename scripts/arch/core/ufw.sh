#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

require_root

log::banner "Security" "UFW firewall"

log::info "Installing ufw"
sudo pacman -S --needed --noconfirm ufw ufw-docker

log::info "Setting default policy (deny incoming, allow outgoing)"
sudo ufw default deny incoming
sudo ufw default allow outgoing

log::info "Enabling ufw"
sudo ufw --force enable
sudo systemctl enable ufw.service

log::ok "UFW configured"
