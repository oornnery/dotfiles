#!/usr/bin/env bash
# desktop/gnome-extensions.sh — install + enable + configure GNOME extensions.
#
# Reads UUIDs from gnome-extensions.txt and pulls each from extensions.gnome.org
# via `gnome-shell-extension-installer` (AUR). Best-effort: failed installs
# (version mismatch / removed extension) print a warning and continue.
#
# After installing, you MUST logout + login (or restart Shell on X11) for
# GNOME to register the new extensions.

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../lib/detect.sh"

USER_NAME="${USER_NAME:-${SUDO_USER:-$USER}}"
EXT_LIST="$(dirname "${BASH_SOURCE[0]}")/gnome-extensions.txt"

require_root
detect::system

log::banner "Desktop" "GNOME extensions (auto-install)"

if [[ $IS_WSL -eq 1 || $IS_VM -eq 1 ]]; then
    log::skip "WSL/VM: skipping"
    exit 0
fi

if [[ ! -f "$EXT_LIST" ]]; then
    die "Extension list missing: $EXT_LIST"
fi

# ─── Installer (AUR) ───────────────────────────────────────────────────────

if ! sudo -u "$USER_NAME" -H bash -c 'command -v paru' >/dev/null 2>&1; then
    die "paru not installed — run core/paru.sh first"
fi

log::info "Ensuring gnome-shell-extension-installer (AUR)"
sudo -u "$USER_NAME" -H paru -S --needed --noconfirm gnome-shell-extension-installer

# ─── Helpers ───────────────────────────────────────────────────────────────

_run_user() {
    sudo -u "$USER_NAME" -H "$@"
}

_run_session() {
    # dbus-run-session for gsettings + gnome-extensions enable to find a bus
    sudo -u "$USER_NAME" -H dbus-run-session -- "$@" 2>/dev/null
}

# UUIDs from the curated list (drops comments + blank lines).
mapfile -t EXTENSIONS < <(grep -E '^[a-z0-9]' "$EXT_LIST")
log::info "Found ${#EXTENSIONS[@]} extensions in $EXT_LIST"

# Detect installed Shell version (used by the installer for version pinning).
SHELL_VERSION="$(_run_session gnome-shell --version 2>/dev/null | awk '{print $3}')"
[[ -n "$SHELL_VERSION" ]] && log::info "GNOME Shell version: $SHELL_VERSION"

# ─── Install ───────────────────────────────────────────────────────────────

log::step "Installing extensions"

installed=()
skipped=()

for uuid in "${EXTENSIONS[@]}"; do
    if _run_user gnome-shell-extension-installer --yes "$uuid" 2>/dev/null; then
        log::ok "  installed: $uuid"
        installed+=("$uuid")
    else
        log::warn "  failed: $uuid (no compatible build for GNOME $SHELL_VERSION?)"
        skipped+=("$uuid")
    fi
done

# ─── Enable ────────────────────────────────────────────────────────────────

log::step "Enabling extensions"

# Need a Shell reload so the just-installed extensions are visible to
# `gnome-extensions`. On Wayland this requires logout/login — we can't
# force it. Best-effort: try enabling now; the user re-runs `enable`
# after logout if needed.

for uuid in "${installed[@]}"; do
    if _run_session gnome-extensions enable "$uuid"; then
        log::ok "  enabled: $uuid"
    else
        log::warn "  could not enable now: $uuid (try after relogin)"
    fi
done

# ─── Per-extension gsettings (sensible defaults) ────────────────────────────

log::step "Applying per-extension defaults"

_gset() {
    _run_session gsettings set "$@" 2>/dev/null \
        || log::warn "    gsettings set $* failed"
}

# Dash to Dock — floating, bottom, autohide
if printf '%s\n' "${installed[@]}" | grep -q 'dash-to-dock@'; then
    log::info "  Dash to Dock"
    _gset org.gnome.shell.extensions.dash-to-dock dock-position           'BOTTOM'
    _gset org.gnome.shell.extensions.dash-to-dock dock-fixed              false
    _gset org.gnome.shell.extensions.dash-to-dock extend-height           false
    _gset org.gnome.shell.extensions.dash-to-dock intellihide             true
    _gset org.gnome.shell.extensions.dash-to-dock transparency-mode       'DYNAMIC'
    _gset org.gnome.shell.extensions.dash-to-dock dash-max-icon-size      40
    _gset org.gnome.shell.extensions.dash-to-dock click-action            'minimize-or-overview'
fi

# Just Perfection — hide activities button + adjust panel
if printf '%s\n' "${installed[@]}" | grep -q 'just-perfection'; then
    log::info "  Just Perfection"
    _gset org.gnome.shell.extensions.just-perfection activities-button    false
    _gset org.gnome.shell.extensions.just-perfection app-menu             false
    _gset org.gnome.shell.extensions.just-perfection panel-size           28
    _gset org.gnome.shell.extensions.just-perfection startup-status       0
fi

# Blur My Shell — enable subtle blur on panel + overview
if printf '%s\n' "${installed[@]}" | grep -q 'blur-my-shell'; then
    log::info "  Blur My Shell"
    _gset org.gnome.shell.extensions.blur-my-shell.panel blur             true
    _gset org.gnome.shell.extensions.blur-my-shell.panel sigma            20
    _gset org.gnome.shell.extensions.blur-my-shell.overview blur          true
    _gset org.gnome.shell.extensions.blur-my-shell.applications blur      true
fi

# Tiling Shell — enable tiling + reasonable gaps
if printf '%s\n' "${installed[@]}" | grep -q 'tilingshell@'; then
    log::info "  Tiling Shell"
    _gset org.gnome.shell.extensions.tilingshell inner-gaps               8
    _gset org.gnome.shell.extensions.tilingshell outer-gaps               8
    _gset org.gnome.shell.extensions.tilingshell snap-assist              true
fi

# Caffeine — start enabled on login
if printf '%s\n' "${installed[@]}" | grep -q 'caffeine@'; then
    log::info "  Caffeine"
    _gset org.gnome.shell.extensions.caffeine show-indicator              'always'
    _gset org.gnome.shell.extensions.caffeine toggle-state                false
fi

# Clipboard History — reasonable history size
if printf '%s\n' "${installed[@]}" | grep -q 'clipboard-history'; then
    log::info "  Clipboard History"
    _gset org.gnome.shell.extensions.clipboard-history history-size       50
    _gset org.gnome.shell.extensions.clipboard-history paste-on-selection true
fi

# Rounded Window Corners — radius
if printf '%s\n' "${installed[@]}" | grep -q 'rounded-window-corners'; then
    log::info "  Rounded Window Corners"
    _gset org.gnome.shell.extensions.rounded-window-corners-reborn global-rounded-corner-settings \
        "{'padding': <{'top': uint32 1, 'bottom': uint32 1, 'left': uint32 1, 'right': uint32 1}>, 'keep_rounded_corners': <{'maximized': false, 'fullscreen': false}>, 'border_radius': <uint32 12>, 'smoothing': <uint32 0>, 'enabled': true}" \
        || true
fi

# ─── Summary ───────────────────────────────────────────────────────────────

echo
log::ok "Installed ${#installed[@]} / ${#EXTENSIONS[@]} extensions"
(( ${#skipped[@]} > 0 )) && log::warn "Skipped: ${skipped[*]}"
log::info "Logout and login again so GNOME Shell registers the new extensions."
log::info "Then verify: gnome-extensions list --enabled"
