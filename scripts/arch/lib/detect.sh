#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

detect::system() {
    log::step "Detecting system"

    CPU_VENDOR="unknown"
    log::info "Detecting CPU vendor"
    if grep -q "GenuineIntel" /proc/cpuinfo; then
        CPU_VENDOR="intel"
        log::ok "Detected Intel CPU"
    elif grep -q "AuthenticAMD" /proc/cpuinfo; then
        CPU_VENDOR="amd"
        log::ok "Detected AMD CPU"
    else
        log::warn "Unknown CPU vendor"
    fi

    IS_WSL=0
    log::info "Detecting WSL"
    if grep -qEi "(Microsoft|WSL)" /proc/version &>/dev/null; then
        IS_WSL=1
        log::ok "Detected WSL"
    else
        log::skip "Not running in WSL"
    fi

    VM_TYPE="$(systemd-detect-virt 2>/dev/null || true)"
    [[ -z "$VM_TYPE" ]] && VM_TYPE="none"
    IS_VM=0
    log::info "Detecting virtual machine"
    if [[ "$VM_TYPE" != "none" && $IS_WSL -eq 0 ]]; then
        IS_VM=1
        log::ok "Detected virtual machine: $VM_TYPE"
    else
        log::skip "Not running in a virtual machine"
    fi

    IS_LAPTOP=0
    CHASSIS_TYPE="unknown"
    log::info "Detecting chassis type"
    if [[ $IS_WSL -eq 0 && $IS_VM -eq 0 && -r /sys/class/dmi/id/chassis_type ]]; then
        CHASSIS_TYPE="$(cat /sys/class/dmi/id/chassis_type 2>/dev/null || true)"
        case "$CHASSIS_TYPE" in
            8|9|10|14)
                IS_LAPTOP=1
                log::ok "Detected laptop (chassis type $CHASSIS_TYPE)" ;;
            *)
                log::ok "Not a laptop (chassis type $CHASSIS_TYPE)" ;;
        esac
    else
        log::skip "Skipping laptop detection (WSL/VM or missing chassis_type)"
    fi

    GPU_VENDORS=()
    log::info "Detecting GPU vendors"
    if [[ $IS_WSL -eq 0 && $IS_VM -eq 0 && -d /sys/class/drm ]]; then
        local vendor_files=(/sys/class/drm/card*/device/vendor)
        if (( ${#vendor_files[@]} > 0 )) && [[ -f "${vendor_files[0]}" ]]; then
            while IFS= read -r v; do
                case "$v" in
                    0x1002) GPU_VENDORS+=("amd") ;;
                    0x8086) GPU_VENDORS+=("intel") ;;
                    0x10de) GPU_VENDORS+=("nvidia") ;;
                esac
            done < <(cat "${vendor_files[@]}" 2>/dev/null | sort -u)
        fi
        if (( ${#GPU_VENDORS[@]} > 0 )); then
            log::ok "Detected GPU vendors: ${GPU_VENDORS[*]}"
        else
            log::warn "No GPU vendors detected"
        fi
    else
        log::skip "Skipping GPU detection (WSL/VM or missing /sys/class/drm)"
    fi

    DMI_VENDOR="unknown"
    log::info "Detecting system vendor"
    if [[ $IS_WSL -eq 0 && -r /sys/class/dmi/id/sys_vendor ]]; then
        DMI_VENDOR="$(cat /sys/class/dmi/id/sys_vendor 2>/dev/null || true)"
        log::ok "Detected system vendor: $DMI_VENDOR"
    else
        log::skip "Skipping system vendor detection (WSL or missing sys_vendor)"
    fi

    ROOT_FS="$(findmnt -no FSTYPE / 2>/dev/null || true)"
    log::info "Detecting root filesystem"
    if [[ -n "$ROOT_FS" ]]; then
        log::ok "Detected root filesystem: $ROOT_FS"
    else
        log::warn "Unable to detect root filesystem"
    fi

    HAS_LUKS=0
    log::info "Detecting LUKS encryption"
    if [[ $IS_WSL -eq 0 && -d /dev/mapper ]]; then
        if findmnt -no SOURCE / 2>/dev/null | grep -q '^/dev/mapper/'; then
            HAS_LUKS=1
            log::ok "Detected LUKS-encrypted root filesystem"
        else
            log::skip "Root filesystem is not LUKS-encrypted"
        fi
    else
        log::skip "Skipping LUKS detection (WSL or missing /dev/mapper)"
    fi

    CURRENT_DM="none"
    log::info "Detecting current display manager"
    if [[ -L /etc/systemd/system/display-manager.service ]]; then
        CURRENT_DM="$(basename "$(readlink -f /etc/systemd/system/display-manager.service)" .service)"
        log::ok "Current display manager: $CURRENT_DM"
    else
        log::skip "No display manager detected"
    fi

    CURRENT_KERNEL="$(uname -r)"
    log::info "Detecting kernel version"
    log::ok "Current kernel version: $CURRENT_KERNEL"

    export CPU_VENDOR IS_WSL IS_VM VM_TYPE IS_LAPTOP GPU_VENDORS CHASSIS_TYPE DMI_VENDOR ROOT_FS HAS_LUKS CURRENT_DM CURRENT_KERNEL
}

detect::audio() {
    AUDIO_DRIVERS=()
    log::step "Detecting audio hardware"
    [[ -d /sys/class/sound ]] || return 0

    while IFS= read -r card; do
        driver="$(grep '^DRIVER=' "$card/device/uevent" \
          2>/dev/null | cut -d= -f2- || true)"

        [[ -n "$driver" ]] && AUDIO_DRIVERS+=("$driver")

    done < <(find /sys/class/sound -maxdepth 1 -name 'card*')
    log::ok "Detected audio drivers: ${AUDIO_DRIVERS[*]:-none}"
    export AUDIO_DRIVERS
}

detect::bluetooth() {
    HAS_BLUETOOTH=0

    if compgen -G "/sys/class/bluetooth/hci*" > /dev/null; then
        HAS_BLUETOOTH=1

        local adapters=()

        while IFS= read -r hci; do
            adapters+=("$(basename "$hci")")
        done < <(find /sys/class/bluetooth -maxdepth 1 -name 'hci*')

        log::ok "Bluetooth adapters detected: ${adapters[*]}"
    else
        log::warn "No Bluetooth adapters detected"
    fi

    export HAS_BLUETOOTH
}


detect::summary() {
    log::step "System detection summary"
    log::info "CPU vendor: $CPU_VENDOR"
    log::info "Running in WSL: $IS_WSL"
    log::info "Running in VM: $IS_VM ($VM_TYPE)"
    log::info "Is laptop: $IS_LAPTOP (chassis type: $CHASSIS_TYPE)"
    if (( ${#GPU_VENDORS[@]} > 0 )); then
        log::info "GPU vendors: ${GPU_VENDORS[*]}"
    else
        log::info "GPU vendors: none detected"
    fi
    log::info "System vendor (DMI): $DMI_VENDOR"
    log::info "Root filesystem: $ROOT_FS"
    log::info "LUKS-encrypted root: $HAS_LUKS"
    log::info "Display manager: $CURRENT_DM"
    log::info "Kernel version: $CURRENT_KERNEL"
}
