#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

bootloader::detect() {
    if [[ -d /boot/loader/entries ]]; then
        echo "systemd-boot"
        return
    fi

    if [[ -f /etc/default/grub ]]; then
        echo "grub"
        return
    fi

    echo "unknown"
}

bootloader::append_kernel_param() {
    local param="$1"
    local bootloader
    bootloader="$(bootloader::detect)"

    case "$bootloader" in
        systemd-boot)
            for f in /boot/loader/entries/*.conf; do
                [[ -f "$f" ]] || continue

                if grep -qw "$param" "$f"; then
                    log::skip "$param already exists in $(basename "$f")"
                    continue
                fi

                snapshot "$f"
                sed -i "/^options / s/\$/ $param/" "$f"
                log::ok "Added '$param' to $(basename "$f")"
            done
            ;;
        grub)
            if grep -qw "$param" /etc/default/grub; then
                log::skip "$param already exists in GRUB"
                return
            fi

            snapshot /etc/default/grub
            sed -i \
                "s#GRUB_CMDLINE_LINUX_DEFAULT=\"\(.*\)\"#GRUB_CMDLINE_LINUX_DEFAULT=\"\1 $param\"#" \
                /etc/default/grub

            if command -v grub-mkconfig &>/dev/null; then
                grub-mkconfig -o /boot/grub/grub.cfg
                log::ok "GRUB config regenerated"
            else
                log::warn "grub-mkconfig not found"
            fi
            ;;
        *)
            log::warn "Unknown bootloader"
            log::warn "Add manually: $param"
            ;;
    esac
}
