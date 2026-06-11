#!/usr/bin/env bash
# desktop/gnome-rice.sh — GNOME visual + workflow upgrade.
#
# Sits on top of desktop/gnome.sh. Installs theming packages, applies
# gsettings (dark mode, fonts, button layout, dynamic workspaces),
# leaves extension install for the user (use Extension Manager + the
# list in gnome-extensions.txt).
#
# Idempotent: re-run safely. gsettings calls overwrite previous values.

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../lib/detect.sh"

USER_NAME="${USER_NAME:-${SUDO_USER:-$USER}}"
ENABLE_GNOME_RICE="${ENABLE_GNOME_RICE:-1}"
GNOME_RICE_PROFILE="${GNOME_RICE_PROFILE:-modern}"   # minimal | modern | wm-like

require_root
detect::system

log::banner "Desktop" "GNOME rice ($GNOME_RICE_PROFILE)"

if [[ "$ENABLE_GNOME_RICE" != "1" ]]; then
    log::skip "ENABLE_GNOME_RICE=0 in arch.conf"
    exit 0
fi
if [[ $IS_WSL -eq 1 || $IS_VM -eq 1 ]]; then
    log::skip "WSL/VM: skipping GNOME rice"
    exit 0
fi

# ─── Pacotes de tema + extensão infra ──────────────────────────────────────

log::info "Installing GNOME theming + extension infra (pacman)"
sudo pacman -S --needed --noconfirm \
    gnome-tweaks \
    gnome-shell-extensions \
    gnome-browser-connector \
    dconf-editor \
    extension-manager \
    xdg-desktop-portal-gnome \
    libadwaita \
    adw-gtk-theme \
    papirus-icon-theme \
    wl-clipboard cliphist \
    grim slurp swappy \
    brightnessctl playerctl pavucontrol \
    fastfetch

# ─── AUR extras (opt-in via paru) ──────────────────────────────────────────

if sudo -u "$USER_NAME" -H bash -c 'command -v paru' >/dev/null 2>&1; then
    log::info "Installing AUR extras (per-package, tolerate failures)"
    for aur_pkg in bibata-cursor-theme-bin morewaita-icon-theme; do
        if sudo -u "$USER_NAME" -H paru -S --needed --noconfirm "$aur_pkg"; then
            log::ok "  $aur_pkg"
        else
            log::warn "  $aur_pkg failed — skipping"
        fi
    done
    # gradience was removed from AUR in late 2025 — skip it.
else
    log::warn "paru not installed — skipping AUR extras (cursor, icons)"
fi

# ─── gsettings wrapper (drops priv + dbus-run-session) ─────────────────────

_gset() {
    sudo -u "$USER_NAME" -H dbus-run-session -- gsettings set "$@" 2>/dev/null \
        || log::warn "gsettings set $* failed"
}

# ─── Interface (dark + fonts + theme) ──────────────────────────────────────

log::step "Applying interface settings"

_gset org.gnome.desktop.interface color-scheme            'prefer-dark'
_gset org.gnome.desktop.interface gtk-theme               'adw-gtk3-dark'
_gset org.gnome.desktop.interface icon-theme              'Papirus-Dark'
_gset org.gnome.desktop.interface cursor-theme            'Bibata-Modern-Ice'
_gset org.gnome.desktop.interface font-name               'Inter 10'
_gset org.gnome.desktop.interface document-font-name      'Inter 10'
_gset org.gnome.desktop.interface monospace-font-name     'JetBrainsMono Nerd Font 10'
_gset org.gnome.desktop.interface enable-animations       true
_gset org.gnome.desktop.interface clock-show-seconds      false
_gset org.gnome.desktop.interface clock-show-weekday      true
_gset org.gnome.desktop.interface show-battery-percentage true

# ─── Window manager (mutter) ──────────────────────────────────────────────

log::step "Applying mutter / wm settings"

_gset org.gnome.mutter center-new-windows           true
_gset org.gnome.mutter dynamic-workspaces           true
_gset org.gnome.mutter edge-tiling                  true
_gset org.gnome.mutter workspaces-only-on-primary   false
_gset org.gnome.desktop.wm.preferences button-layout 'appmenu:minimize,maximize,close'
_gset org.gnome.desktop.wm.preferences focus-mode    'click'

# ─── Files (nautilus) ──────────────────────────────────────────────────────

log::step "Nautilus tweaks"

_gset org.gnome.nautilus.preferences show-hidden-files               false
_gset org.gnome.nautilus.preferences show-create-link                true
_gset org.gnome.nautilus.preferences default-folder-viewer           'list-view'
_gset org.gnome.nautilus.list-view default-zoom-level                'small'
_gset org.gnome.nautilus.preferences default-sort-order              'type'

# ─── WM-like keybindings (Super-driven) ────────────────────────────────────

log::step "WM-like keybindings (Super+number, screenshot, terminal)"

# Super + 1..9 → switch to workspace N
for i in 1 2 3 4 5 6 7 8 9; do
    _gset "org.gnome.desktop.wm.keybindings" "switch-to-workspace-$i" "['<Super>$i']"
    _gset "org.gnome.desktop.wm.keybindings" "move-to-workspace-$i"   "['<Super><Shift>$i']"
done

# Super + Enter → open terminal — GNOME 47+ dropped the static `terminal`
# media-key, so wire a custom-keybinding instead. Picks alacritty if
# present, else gnome-terminal as fallback.
TERM_CMD="$(command -v alacritty || command -v gnome-terminal || echo gnome-terminal)"
KEYBIND_PATH="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/term/"
_gset org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['$KEYBIND_PATH']"
_gset "org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$KEYBIND_PATH" name 'Terminal'
_gset "org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$KEYBIND_PATH" command "$TERM_CMD"
_gset "org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$KEYBIND_PATH" binding '<Super>Return'

# Super + Shift + S → screenshot region (works in GNOME ≥ 42)
_gset org.gnome.shell.keybindings show-screenshot-ui "['<Super><Shift>s', 'Print']"

# Super + L → lock. screensaver key still exists in GNOME 50.
_gset org.gnome.settings-daemon.plugins.media-keys screensaver "['<Super>l']"

# ─── Profile-specific tweaks ───────────────────────────────────────────────

case "$GNOME_RICE_PROFILE" in
    minimal)
        log::info "Profile: minimal — skipping aggressive tweaks"
        ;;
    modern)
        log::info "Profile: modern — extra polish"
        # Smaller fixed-spacing on top bar
        _gset org.gnome.shell disable-user-extensions false
        ;;
    wm-like)
        log::info "Profile: wm-like — aggressive workspaces"
        _gset org.gnome.mutter dynamic-workspaces            false
        _gset org.gnome.desktop.wm.preferences num-workspaces 10
        ;;
    *)
        log::warn "Unknown GNOME_RICE_PROFILE: $GNOME_RICE_PROFILE (using defaults)"
        ;;
esac

# ─── Extensions hint ───────────────────────────────────────────────────────

EXT_LIST="$(dirname "${BASH_SOURCE[0]}")/gnome-extensions.txt"
log::ok "GNOME rice base applied"
log::info "Install extensions via Extension Manager (recommended list at $EXT_LIST):"
if [[ -f "$EXT_LIST" ]]; then
    awk '/^[a-z]/ {printf "    - %s\n", $0}' "$EXT_LIST" | head -20
fi
log::info "After installing extensions, re-run this script — it will re-apply gsettings."
