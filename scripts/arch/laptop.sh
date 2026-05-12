#!/usr/bin/env bash
# arch/laptop.sh — Laptop-specific: hwtools, fwupd, gestures, webcam, fingerprint, vendor quirks.
# Power management lives in arch/power.sh (split for clarity).
# shellcheck disable=SC2034  # REBOOT_NEEDED is read by arch.sh
[[ -z "${ARCH_LIB_LOADED:-}" ]] && source "${BASH_SOURCE%/*}/lib.sh"

laptop::hwtools() {
  log::info "Installing hardware tools + fwupd."
  pacman_install \
    lshw inxi hwinfo dmidecode usbutils pciutils \
    fwupd
}

laptop::input_group() {
  id "$USER_NAME" >/dev/null 2>&1 \
    && run gpasswd -a "$USER_NAME" input >/dev/null || true
}

laptop::gestures() {
  log::info "Installing libinput-gestures (3/4-finger touchpad gestures)."
  pacman_install libinput libinput-gestures
  log::info "Config at ~/.config/libinput-gestures.conf (copy from /etc/libinput-gestures.conf)."
}

laptop::webcam() {
  log::info "Installing webcam tools."
  pacman_install v4l-utils guvcview
}

laptop::fingerprint() {
  log::info "Installing fingerprint stack (fprintd)."
  pacman_install fprintd libfprint
  [[ $DRY_RUN -eq 1 ]] && return 0
  grep -q "pam_fprintd.so" /etc/pam.d/sudo && return 0

  snapshot /etc/pam.d/sudo
  if grep -q '^#%PAM-1.0' /etc/pam.d/sudo; then
    sed -i '/^#%PAM-1.0/a auth      [success=1 default=ignore]  pam_fprintd.so' /etc/pam.d/sudo
  else
    log::warn "/etc/pam.d/sudo missing #%PAM-1.0 header; prepending fprintd line directly."
    sed -i '1i auth      [success=1 default=ignore]  pam_fprintd.so' /etc/pam.d/sudo
  fi
  log::info "PAM sudo patched. After reboot, enroll: fprintd-enroll"
  PROMPTS_APPLIED+=("fprintd + PAM sudo")
}

laptop::vendor_quirks() {
  # Vaio ACPI
  if [[ "${DMI_VENDOR:-}" == *VAIO* ]]; then
    log::info "Vaio detected — applying ACPI quirks."
    patch_boot_param "acpi_osi=Linux acpi_backlight=vendor" "acpi_osi=Linux"
    REBOOT_NEEDED=1
    PROMPTS_APPLIED+=("Vaio ACPI quirks")
  fi
  # Dell panel
  if [[ "${DMI_VENDOR:-}" == Dell* ]]; then
    log::info "Dell detected — disabling i915 PSR (panel flicker fix)."
    patch_boot_param "i915.enable_psr=0" "i915.enable_psr"
    REBOOT_NEEDED=1
    PROMPTS_APPLIED+=("Dell panel quirk")
  fi
}

laptop::run() {
  [[ ${IS_LAPTOP:-0} -eq 1 ]] || return 0
  log::step "Laptop stack."
  laptop::hwtools
  laptop::input_group
  # gestures / webcam / fingerprint are opt-in — orchestrator calls them directly.
}
