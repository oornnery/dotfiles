#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../lib/detect.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../lib/bootloader.sh"

require_root
detect::system

log::banner "System" "LUKS systemd-cryptsetup TUI prompt"

if [[ $HAS_LUKS -eq 0 ]]; then
    log::skip "No LUKS root detected"
    exit 0
fi

root_src="$(findmnt -no SOURCE / 2>/dev/null || true)"
LUKS_ROOT_NAME="${root_src##*/}"
backing="$(sudo cryptsetup status "$LUKS_ROOT_NAME" 2>/dev/null | awk '/device:/ {print $2}')"
LUKS_ROOT_UUID="$(sudo blkid -s UUID -o value "$backing" 2>/dev/null || true)"

if [[ -z "$LUKS_ROOT_UUID" || -z "$LUKS_ROOT_NAME" ]]; then
    die "Could not resolve LUKS_ROOT_UUID/LUKS_ROOT_NAME"
fi

log::info "LUKS root: /dev/mapper/$LUKS_ROOT_NAME (UUID=$LUKS_ROOT_UUID)"

log::info "Installing cryptsetup"
sudo pacman -S --needed --noconfirm cryptsetup

log::step "Patching /etc/mkinitcpio.conf to systemd hooks"

if grep -E '^HOOKS=.*systemd' /etc/mkinitcpio.conf >/dev/null 2>&1 \
   && grep -E '^HOOKS=.*sd-encrypt' /etc/mkinitcpio.conf >/dev/null 2>&1; then
    log::skip "mkinitcpio.conf already uses systemd hooks"
else
    snapshot /etc/mkinitcpio.conf
    sudo sed -i -E 's|^HOOKS=.*|HOOKS=(base systemd autodetect microcode modconf kms sd-vconsole block sd-encrypt filesystems fsck)|' \
        /etc/mkinitcpio.conf
    log::ok "Rewrote HOOKS= to use sd-encrypt"
fi

log::step "Patching bootloader cmdline"

CMDLINE="rd.luks.name=${LUKS_ROOT_UUID}=${LUKS_ROOT_NAME} root=/dev/mapper/${LUKS_ROOT_NAME}"

case "$(bootloader::detect)" in
    systemd-boot)
        for f in /boot/loader/entries/*.conf; do
            [[ -f "$f" ]] || continue
            if grep -q "rd.luks.name=${LUKS_ROOT_UUID}" "$f"; then
                log::skip "$f already migrated"
                continue
            fi
            if ! grep -q "cryptdevice=UUID=${LUKS_ROOT_UUID}" "$f"; then
                log::skip "$f has no cryptdevice= for this UUID"
                continue
            fi
            snapshot "$f"
            sudo sed -i "s|cryptdevice=UUID=${LUKS_ROOT_UUID}:${LUKS_ROOT_NAME}[^ ]*|${CMDLINE}|" "$f"
            sudo sed -i "s|root=/dev/mapper/${LUKS_ROOT_NAME}[[:space:]]*root=/dev/mapper/${LUKS_ROOT_NAME}|root=/dev/mapper/${LUKS_ROOT_NAME}|" "$f"
            log::ok "Migrated $(basename "$f")"
        done
        ;;
    grub)
        if grep -q "rd.luks.name=${LUKS_ROOT_UUID}" /etc/default/grub; then
            log::skip "GRUB already migrated"
        elif grep -q "cryptdevice=UUID=${LUKS_ROOT_UUID}" /etc/default/grub; then
            snapshot /etc/default/grub
            sudo sed -i "s|cryptdevice=UUID=${LUKS_ROOT_UUID}:${LUKS_ROOT_NAME}|${CMDLINE}|" /etc/default/grub
            sudo grub-mkconfig -o /boot/grub/grub.cfg
            log::ok "GRUB migrated"
        else
            log::skip "GRUB has no cryptdevice= for this UUID"
        fi
        ;;
    *)
        log::warn "Unknown bootloader. Migrate cmdline manually to: $CMDLINE"
        ;;
esac

log::step "Regenerating initramfs"
sudo mkinitcpio -P

log::step "Sanity check"
img=/boot/initramfs-linux.img
if [[ -f "$img" ]] && command -v lsinitcpio >/dev/null 2>&1; then
    if sudo lsinitcpio "$img" 2>/dev/null | grep -q 'usr/lib/systemd/systemd-cryptsetup'; then
        log::ok "systemd-cryptsetup present in initramfs"
    else
        die "systemd-cryptsetup not in initramfs. Restore /etc/mkinitcpio.conf from snapshot and regenerate."
    fi
else
    log::warn "Could not verify initramfs (lsinitcpio missing)"
fi

log::warn "REBOOT required to use the new TUI LUKS prompt"
