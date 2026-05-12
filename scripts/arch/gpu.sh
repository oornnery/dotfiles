#!/usr/bin/env bash
# arch/gpu.sh — Video drivers: mesa, vulkan-{intel,radeon,nouveau}, xf86-video-*, intel-media-driver, libva-*.
# shellcheck disable=SC2034  # REBOOT_NEEDED is read by arch.sh
[[ -z "${ARCH_LIB_LOADED:-}" ]] && source "${BASH_SOURCE%/*}/lib.sh"

gpu::base() {
  pacman_install \
    mesa \
    vulkan-icd-loader \
    libva-utils vdpauinfo
  if multilib_enabled; then
    pacman_install lib32-mesa lib32-vulkan-icd-loader
  fi
}

gpu::amd() {
  log::info "Installing AMD GPU stack (mesa + vulkan-radeon + xf86-video-amdgpu/ati)."
  # Note: mesa-vdpau + libva-mesa-driver are now provided by mesa itself.
  pacman_install \
    vulkan-radeon \
    xf86-video-amdgpu xf86-video-ati \
    radeontop
  multilib_enabled && pacman_install lib32-vulkan-radeon
}

gpu::intel() {
  log::info "Installing Intel GPU stack (mesa + vulkan-intel + intel-media-driver)."
  pacman_install \
    vulkan-intel \
    intel-media-driver libva-intel-driver \
    intel-gpu-tools
  multilib_enabled && pacman_install lib32-vulkan-intel
}

gpu::nouveau_nvidia() {
  log::info "Installing Nouveau (FOSS NVIDIA fallback) + vulkan-nouveau."
  pacman_install xf86-video-nouveau vulkan-nouveau
}

gpu::nvidia_proprietary() {
  log::info "Installing nvidia-open proprietary drivers."
  log::warn "If you also installed linux-zen/linux-lts, switch to nvidia-open-dkms."
  pacman_install \
    nvidia-open nvidia-utils nvidia-settings \
    libva-nvidia-driver
  multilib_enabled && pacman_install lib32-nvidia-utils
  REBOOT_NEEDED=1
  log::warn "If 'nvidia-open' fails on older Maxwell/Pascal cards, retry with proprietary 'nvidia'."
  PROMPTS_APPLIED+=("NVIDIA drivers")
}

# gpu::run handles auto-detection. Nvidia proprietary requires explicit prompt
# in the orchestrator; this module just installs nouveau + vulkan-nouveau as a baseline.
gpu::run() {
  log::step "Installing GPU stack."

  # Skip on WSL (uses WSLg via host driver).
  if [[ ${IS_WSL:-0} -eq 1 ]]; then
    log::info "WSL — using WSLg/host driver; skipping native GPU stack."
    return 0
  fi

  gpu::base

  local g found=0
  for g in "${GPU_VENDORS[@]:-}"; do
    case "$g" in
      amd)    gpu::amd;    found=1 ;;
      intel)  gpu::intel;  found=1 ;;
      nvidia)
        # Always install nouveau as a safe baseline; orchestrator may also call
        # gpu::nvidia_proprietary if user opts in.
        gpu::nouveau_nvidia
        found=1
        ;;
    esac
  done

  if [[ $found -eq 0 ]]; then
    log::info "No discrete GPU vendor detected; installing nouveau as generic fallback."
    pacman_install xf86-video-nouveau vulkan-nouveau || true
  fi
}
