#!/usr/bin/env bash
# arch/vm-guest.sh — VM guest tools per detected hypervisor.
[[ -z "${ARCH_LIB_LOADED:-}" ]] && source "${BASH_SOURCE%/*}/lib.sh"

vm_guest::run() {
  [[ ${IS_VM:-0} -eq 1 ]] || return 0
  log::step "Installing VM guest tools for: $VM_TYPE"
  case "$VM_TYPE" in
    qemu|kvm)
      pacman_install mesa qemu-guest-agent spice-vdagent xf86-video-qxl
      run systemctl enable qemu-guest-agent.service spice-vdagent.service
      SERVICES_ENABLED+=(qemu-guest-agent spice-vdagent)
      ;;
    oracle)
      pacman_install virtualbox-guest-utils
      run systemctl enable vboxservice.service
      SERVICES_ENABLED+=(vboxservice)
      id "$USER_NAME" >/dev/null 2>&1 && run gpasswd -a "$USER_NAME" vboxsf
      ;;
    vmware)
      pacman_install open-vm-tools xf86-video-vmware
      run systemctl enable vmtoolsd.service vmware-vmblock-fuse.service
      SERVICES_ENABLED+=(vmtoolsd vmware-vmblock-fuse)
      ;;
    microsoft)
      pacman_install hyperv
      run systemctl enable hv_fcopy_daemon.service hv_kvp_daemon.service hv_vss_daemon.service
      SERVICES_ENABLED+=(hv_fcopy_daemon hv_kvp_daemon hv_vss_daemon)
      ;;
    *)
      log::warn "VM type '$VM_TYPE' has no known guest-tools package. Skipping."
      ;;
  esac
}
