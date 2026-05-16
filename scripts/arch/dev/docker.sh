#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

USER_NAME="${USER_NAME:-${SUDO_USER:-$USER}}"

require_root

log::banner "Dev" "Docker + Podman + lazydocker"

log::info "Installing container stack"
sudo pacman -S --needed --noconfirm \
    docker docker-compose docker-buildx \
    podman buildah skopeo \
    distrobox lazydocker

log::info "Enabling docker.socket (lazy activation)"
sudo systemctl enable docker.socket

if id "$USER_NAME" >/dev/null 2>&1; then
    log::info "Adding $USER_NAME to docker group"
    sudo gpasswd -a "$USER_NAME" docker || true
    log::warn "Docker group ≈ root. Log out/in to apply group."
fi

log::ok "Container stack installed"
