#!/usr/bin/env bash
# arch/devops.sh — Docker, Podman, distrobox, lazydocker.
[[ -z "${ARCH_LIB_LOADED:-}" ]] && source "${BASH_SOURCE%/*}/lib.sh"

devops::run() {
  log::step "Installing devops stack (containers)."
  pacman_install \
    docker docker-compose docker-buildx \
    podman buildah skopeo \
    distrobox lazydocker

  # Docker: socket activation (avoids dockerd always running)
  run systemctl enable docker.socket
  SERVICES_ENABLED+=(docker.socket)

  if id "$USER_NAME" >/dev/null 2>&1; then
    run gpasswd -a "$USER_NAME" docker
    log::warn "User added to 'docker' group — re-login required. Note: docker group ≈ root."
  fi

  PROMPTS_APPLIED+=("docker + podman + distrobox")
}
