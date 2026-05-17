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
# same screens as the session.
#
# Modern Arch GDM uses DynamicUser-style per-seat config dirs:
#   /var/lib/gdm/seat0/config/   (mode 700, owned by the dynamic GDM UID)
# Mutter reads $XDG_CONFIG_HOME/monitors.xml from there.
# The legacy /var/lib/gdm/.config/ path is ignored.
_user="${SUDO_USER:-${USER_NAME:-$USER}}"
user_monitors="$(getent passwd "$_user" | cut -d: -f6)/.config/monitors.xml"
seat_cfg="/var/lib/gdm/seat0/config"
if [[ ! -f "$user_monitors" ]]; then
    log::skip "No ${user_monitors} yet — open GNOME Settings → Displays once, then re-run"
elif [[ ! -d "$seat_cfg" ]]; then
    log::skip "${seat_cfg} not present yet — start GDM at least once, then re-run"
else
    dyn_uid=$(stat -c '%u' "$seat_cfg")
    dyn_gid=$(stat -c '%g' "$seat_cfg")
    log::info "Syncing monitors.xml to ${seat_cfg}/ (uid=${dyn_uid} gid=${dyn_gid})"
    sudo install -m 600 -o "$dyn_uid" -g "$dyn_gid" \
        "$user_monitors" "$seat_cfg/monitors.xml"
    # Clean up the old wrong path if a previous run left a file there.
    if [[ -f /var/lib/gdm/.config/monitors.xml ]]; then
        sudo rm -f /var/lib/gdm/.config/monitors.xml
        sudo rmdir --ignore-fail-on-non-empty /var/lib/gdm/.config 2>/dev/null || true
    fi
    log::ok "GDM greeter will follow your GNOME monitor layout (restart gdm to apply)"
fi

sudo systemctl enable gdm.service

log::ok "GDM enabled — edit gdm/etc/gdm/custom.conf to tweak (WaylandEnable, autologin)"
