#!/usr/bin/env bash
# game/gaming.sh — gaming stack: Steam, Lutris, Heroic, wine, gamemode,
# controller drivers.
#
# Requires multilib enabled in /etc/pacman.conf (core/pacman.sh does this).
# AUR packages (Heroic) need paru — install core/paru.sh first.

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

USER_NAME="${USER_NAME:-${SUDO_USER:-$USER}}"

require_root

log::banner "Game" "Steam + Heroic + wine + gamemode + controllers"

if ! grep -q '^\[multilib\]' /etc/pacman.conf; then
    die "[multilib] not enabled in /etc/pacman.conf — run core/pacman.sh first"
fi

# ─── Base gaming stack (pacman) ─────────────────────────────────────────────

log::info "Installing Steam, Lutris, wine, gamemode, mangohud"
sudo pacman -S --needed --noconfirm \
    steam lutris \
    wine wine-mono wine-gecko winetricks \
    gamemode lib32-gamemode \
    mangohud lib32-mangohud

# ─── Controllers ───────────────────────────────────────────────────────────

log::info "Installing controller drivers + mappers"
sudo pacman -S --needed --noconfirm sc-controller

# udev rules for game controllers (Steam, Xbox, DS4) are usually shipped
# by their respective packages; force-add user to input/uinput groups
# so SDL2 mapping and xpadneo (if installed) work without root.
if id "$USER_NAME" >/dev/null 2>&1; then
    sudo gpasswd -a "$USER_NAME" input  || true
    sudo gpasswd -a "$USER_NAME" uucp   || true   # serial controllers
fi

# Load + persist uinput kernel module (sc-controller needs it to create
# the virtual Xbox controller that translates DS4/Steam Controller input).
sudo modprobe uinput || true
echo uinput | sudo tee /etc/modules-load.d/uinput.conf >/dev/null

# Reload udev rules so the sc-controller package's rules take effect
# without needing a reboot. Re-plug or re-pair the controller after this.
sudo udevadm control --reload-rules
sudo udevadm trigger

# ─── AUR launchers (Heroic for Epic / GOG / Amazon) ────────────────────────

if sudo -u "$USER_NAME" -H bash -c 'command -v paru' >/dev/null 2>&1; then
    log::info "Installing AUR extras (Heroic + xboxdrv)"
    sudo -u "$USER_NAME" -H paru -S --needed --noconfirm \
        heroic-games-launcher-bin \
        xboxdrv
else
    log::warn "paru not installed — skipping AUR extras. Run core/paru.sh then re-run this."
fi

log::ok "Gaming stack installed"
log::info "After install:"
log::info "  - Steam → Settings → Compatibility → Enable Steam Play for all titles"
log::info "  - Heroic Launcher → log into Epic / GOG / Amazon accounts"
log::info "  - sc-controller-daemon  # to use a DS4 as a virtual Xbox controller"
log::info "  - Per-game launch options: gamemoderun mangohud %command%"
