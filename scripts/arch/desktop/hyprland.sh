#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../lib/detect.sh"

USER_NAME="${USER_NAME:-${SUDO_USER:-$USER}}"
DOTFILES_DIR="${DOTFILES_DIR:-/home/$USER_NAME/dotfiles}"

require_root
detect::system

log::banner "Desktop" "Hyprland"

if [[ $IS_WSL -eq 1 ]]; then
    log::skip "WSL: use Windows desktop or WSLg"
    exit 0
fi

log::info "Installing Hyprland packages (official repos)"
sudo pacman -S --needed --noconfirm \
    hyprland hypridle hyprlock hyprshot hyprpaper hyprsunset hyprpicker \
    xdg-desktop-portal-hyprland xdg-desktop-portal-gtk \
    uwsm \
    waybar swaync mako \
    swayosd \
    wofi rofi-wayland \
    swww nwg-look kvantum \
    qt5-wayland qt6-wayland qt5ct qt6ct \
    xorg-xwayland \
    hyprpolkitagent polkit-gnome \
    grim slurp satty swappy \
    wl-clipboard cliphist \
    woff2-font-awesome \
    stow

# AUR-only: dropped from extra/ or only exist there.
#   hyprland-qtutils  → AUR (Qt5/Qt6 utility libs for hyprland)
#   xdg-terminal-exec → AUR (spec implementation, sometimes split as -git)
#   wlogout           → AUR (logout screen — moved out of community)
if sudo -u "$USER_NAME" -H bash -c 'command -v paru' >/dev/null 2>&1; then
    log::info "Installing AUR extras (hyprland-qtutils, xdg-terminal-exec, wlogout)"
    for aur_pkg in hyprland-qtutils xdg-terminal-exec wlogout; do
        if sudo -u "$USER_NAME" -H paru -S --needed --noconfirm "$aur_pkg"; then
            log::ok "  $aur_pkg"
        else
            log::warn "  $aur_pkg failed — try '$aur_pkg-git' manually if needed"
        fi
    done
else
    log::warn "paru not installed — skipping AUR extras. Run core/paru.sh first."
fi

log::step "Stowing hyprland dotfiles"

if [[ ! -d "$DOTFILES_DIR/hyprland" ]]; then
    log::warn "Stow source missing: $DOTFILES_DIR/hyprland — skipping"
else
    if id "$USER_NAME" >/dev/null 2>&1; then
        user_home="$(getent passwd "$USER_NAME" | cut -d: -f6)"
        sudo -u "$USER_NAME" -H mkdir -p "$user_home/.config" "$user_home/Pictures/screenshots"
        sudo -u "$USER_NAME" -H stow -d "$DOTFILES_DIR" -t "$user_home" -R hyprland \
            || log::warn "stow hyprland failed (file conflict? back up existing ~/.config/hypr)"
        log::ok "Hyprland config stowed"
    else
        log::warn "User $USER_NAME doesn't exist — skipping stow"
    fi
fi

log::ok "Hyprland installed"
