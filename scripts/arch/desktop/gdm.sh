#!/usr/bin/env bash
# desktop/gdm.sh — GDM display manager + stow /etc/gdm/custom.conf.

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../lib/detect.sh"

require_root
detect::system

log::banner "Desktop" "GDM display manager"

if [[ $IS_WSL -eq 1 || $IS_VM -eq 1 ]]; then
    log::skip "WSL/VM: no display manager needed"
    exit 0
fi

log::info "Installing GDM"
sudo pacman -S --needed --noconfirm gdm

log::info "Disabling other display managers"
for unit in sddm.service ly.service greetd.service; do
    if systemctl is-enabled --quiet "$unit" 2>/dev/null; then
        sudo systemctl disable --now "$unit" || true
        log::ok "Disabled $unit"
    fi
done

stow_system gdm

# Mirror user's monitor layout into GDM so the greeter shows on the
# same screens as the session. GDM's mutter reads /var/lib/gdm/.config/monitors.xml.
# On modern Arch GDM has no static `gdm` user (only the gid=120 group),
# so we own the file root:root mode 644 — readable by whatever UID GDM allocates.
_user="${SUDO_USER:-${USER_NAME:-$USER}}"
user_monitors="$(getent passwd "$_user" | cut -d: -f6)/.config/monitors.xml"
if [[ -f "$user_monitors" ]]; then
    log::info "Syncing monitors.xml to /var/lib/gdm/.config/"
    sudo install -d -m 755 /var/lib/gdm/.config
    sudo install -m 644 "$user_monitors" /var/lib/gdm/.config/monitors.xml
    log::ok "GDM greeter will follow your GNOME monitor layout"
else
    log::skip "No ${user_monitors} yet — open GNOME Settings → Displays once, then re-run"
fi

sudo systemctl enable gdm.service

log::ok "GDM enabled — edit gdm/etc/gdm/custom.conf to tweak (WaylandEnable, autologin)"
