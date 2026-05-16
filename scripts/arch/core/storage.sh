#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../lib/detect.sh"

require_root
detect::system

log::banner "Core" "Storage + USB automount"

PKGS=(
    udisks2        # dbus daemon for disk management (mount/unmount)
    udiskie        # automount tray daemon — needed on Hyprland (GNOME uses gvfs)
    polkit         # required for udisks2 mount actions
)

# btrfs root → enable udisks btrfs support
if [[ "$ROOT_FS" == "btrfs" ]]; then
    PKGS+=(udisks2-btrfs)
fi

# usbutils + storage analysis are already in base-utils; here we add only
# the automount stack. lsblk/mount come from util-linux (always present).

log::info "Installing storage stack"
sudo pacman -S --needed --noconfirm "${PKGS[@]}"

log::ok "Storage stack installed"
log::info "Hyprland: udiskie is autostarted via hyprland.conf (exec-once)."
log::info "GNOME: Nautilus already handles automount via gvfs."
