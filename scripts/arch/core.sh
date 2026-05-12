#!/usr/bin/env bash
# arch/core.sh — Base packages, microcode, fonts, archive tools.
# shellcheck disable=SC2034  # REBOOT_NEEDED is read by arch.sh
[[ -z "${ARCH_LIB_LOADED:-}" ]] && source "${BASH_SOURCE%/*}/lib.sh"

core::microcode() {
  # Microcode only on native bare-metal.
  [[ ${IS_WSL:-0} -eq 1 ]] && return 0
  [[ ${IS_VM:-0} -eq 1 ]] && return 0
  case "${CPU_VENDOR:-unknown}" in
    intel)
      log::info "Installing intel-ucode."
      pacman_install intel-ucode
      REBOOT_NEEDED=1
      log::warn "Regenerate bootloader config so microcode loads."
      ;;
    amd)
      log::info "Installing amd-ucode."
      pacman_install amd-ucode
      REBOOT_NEEDED=1
      log::warn "Regenerate bootloader config so microcode loads."
      ;;
  esac
}

core::packages() {
  log::step "Installing core packages."
  pacman_install \
    base-devel sudo git curl wget vim bash stow \
    unzip zip tar gzip bzip2 xz 7zip \
    openssl openssh ca-certificates \
    xdg-utils xdg-user-dirs \
    gvfs gvfs-mtp \
    ntfs-3g \
    less man-db man-pages man-pages-pt_br \
    pacman-contrib pkgfile arch-audit git-delta
}

core::fonts() {
  log::step "Installing fonts (Nerd + Noto)."
  pacman_install \
    ttf-jetbrains-mono-nerd ttf-firacode-nerd \
    noto-fonts noto-fonts-emoji noto-fonts-cjk
}

core::run() {
  core::microcode
  core::packages
  core::fonts
}
