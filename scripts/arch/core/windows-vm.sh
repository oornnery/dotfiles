#!/usr/bin/env bash
# core/windows-vm.sh — Windows 11 VM via docker (dockur/windows).
#
# Creates ~/.config/windows/docker-compose.yml. After the script:
#   cd ~/.config/windows && docker compose up -d
#   xdg-open http://localhost:8006     # noVNC inside the browser
#   # or use any RDP client at localhost:3389
#
# Files shared between host and VM:
#   ~/Windows                    →  visible inside the VM as a network share

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../lib/detect.sh"

USER_NAME="${USER_NAME:-${SUDO_USER:-$USER}}"

require_root
detect::system

log::banner "Core" "Windows 11 VM (dockur/windows)"

if [[ $IS_WSL -eq 1 ]]; then
    log::skip "WSL: use Windows directly, not a nested VM"
    exit 0
fi

if ! command -v docker >/dev/null 2>&1; then
    die "Docker not installed — run dev/docker.sh first"
fi

user_home="$(getent passwd "$USER_NAME" | cut -d: -f6)"
[[ -z "$user_home" ]] && die "Could not resolve home dir for $USER_NAME"

cfg_dir="$user_home/.config/windows"
share_dir="$user_home/Windows"
compose="$cfg_dir/docker-compose.yml"

log::info "Creating ${cfg_dir} and ${share_dir}"
sudo -u "$USER_NAME" mkdir -p "$cfg_dir" "$share_dir"

if [[ -f "$compose" ]]; then
    log::skip "$compose already exists (delete to regenerate)"
else
    log::info "Writing $compose"
    sudo -u "$USER_NAME" tee "$compose" >/dev/null <<'EOF'
# dockur/windows — Windows 11 in a Docker container.
# Upstream: https://github.com/dockur/windows
#
# Adjust RAM_SIZE / CPU_CORES / DISK_SIZE to your host. Defaults are tuned
# for a 16 GB / 8-core laptop running other things alongside.

services:
  windows:
    image: dockurr/windows
    container_name: windows
    environment:
      VERSION: "11"
      RAM_SIZE: "4G"
      CPU_CORES: "4"
      DISK_SIZE: "64G"
      USERNAME: "oornnery"
      PASSWORD: "change-me"
      LANGUAGE: "Portuguese"
      REGION: "pt-BR"
      KEYBOARD: "pt-BR"
    devices:
      - /dev/kvm
      - /dev/net/tun
    cap_add:
      - NET_ADMIN
    ports:
      - 8006:8006   # noVNC web UI
      - 3389:3389/tcp
      - 3389:3389/udp
    volumes:
      - ./storage:/storage
      - ~/Windows:/shared
    restart: unless-stopped
    stop_grace_period: 2m
EOF
    log::ok "Created $compose"
fi

log::ok "Windows VM scaffold ready"
log::info "Start:  cd ${cfg_dir} && docker compose up -d"
log::info "View:   xdg-open http://localhost:8006"
log::info "RDP:    any client at localhost:3389  (user: oornnery, pass: change-me)"
log::warn "Edit ${compose} and change PASSWORD before exposing the container."
