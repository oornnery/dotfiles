#!/usr/bin/env bash
# desktop/gnome-extensions.sh — install + enable + configure GNOME extensions.
#
# Hits extensions.gnome.org's JSON API directly (instead of relying on
# gnome-shell-extension-installer, which gets stale during GNOME major
# releases). For each UUID in gnome-extensions.txt:
#
#   1. Fetch metadata for $SHELL_VERSION (e.g. "50"), fall back to "50.0"
#      then to "$SHELL_VERSION_PREVIOUS" (one major back) with a warning.
#   2. Download the .shell-extension.zip.
#   3. Extract to ~/.local/share/gnome-shell/extensions/<uuid>/.
#   4. glib-compile-schemas if the extension ships schemas.
#   5. `gnome-extensions enable <uuid>` (best-effort — works after Shell
#      reload, which on Wayland needs logout/login).
#   6. Apply known-good gsettings defaults for Dash to Dock, Tiling
#      Shell, Just Perfection, Blur My Shell, etc.
#
# Tolerant: any failed extension prints a warning and moves on.

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
[[ -f "$EXT_LIST" ]] || die "Extension list missing: $EXT_LIST"

# ─── Deps ──────────────────────────────────────────────────────────────────

log::info "Ensuring deps (curl, unzip, jq, glib2)"
sudo pacman -S --needed --noconfirm curl unzip jq glib2

# ─── Helpers ───────────────────────────────────────────────────────────────

_run_user()    { sudo -u "$USER_NAME" -H "$@"; }
_run_session() { sudo -u "$USER_NAME" -H dbus-run-session -- "$@" 2>/dev/null; }

USER_HOME="$(getent passwd "$USER_NAME" | cut -d: -f6)"
EXT_DIR="$USER_HOME/.local/share/gnome-shell/extensions"
_run_user mkdir -p "$EXT_DIR"

# Detect Shell version. GNOME reports e.g. "50.1" — the API key is usually
# just "50" (major). We try both.
SHELL_FULL="$(_run_session gnome-shell --version 2>/dev/null | awk '{print $3}')"
SHELL_MAJOR="${SHELL_FULL%%.*}"
SHELL_PREV=$(( SHELL_MAJOR - 1 ))
log::info "GNOME Shell: $SHELL_FULL (major=$SHELL_MAJOR, prev=$SHELL_PREV)"

# Try to install one extension; echoes the version that worked, or fails.
_install_one() {
    local uuid="$1"
    local zip="/tmp/${uuid//[\/@.]/_}.zip"
    local info sv v_pk
    for sv in "$SHELL_MAJOR" "$SHELL_FULL" "$SHELL_PREV"; do
        info="$(curl -fsSL --max-time 15 \
            "https://extensions.gnome.org/extension-info/?uuid=${uuid}&shell_version=${sv}" 2>/dev/null)"
        [[ -z "$info" || "$info" == "null" ]] && continue

        local pk
        pk="$(printf '%s' "$info" | jq -r '.pk // empty')"
        [[ -z "$pk" || "$pk" == "null" ]] && continue

        # .shell_version_map[$sv].pk is the version pk for this Shell.
        v_pk="$(printf '%s' "$info" | jq -r --arg sv "$sv" '.shell_version_map[$sv].pk // empty')"
        [[ -z "$v_pk" || "$v_pk" == "null" ]] && continue

        local url="https://extensions.gnome.org/download-extension/${uuid}.shell-extension.zip?version_tag=${v_pk}"
        if ! curl -fsSL --max-time 60 -o "$zip" "$url"; then
            continue
        fi

        # Extract directly into the user's extension dir, owned by the user.
        local target="$EXT_DIR/$uuid"
        _run_user rm -rf "$target"
        _run_user mkdir -p "$target"
        _run_user unzip -qo "$zip" -d "$target" || { rm -f "$zip"; continue; }
        rm -f "$zip"

        # Compile schemas if present.
        if [[ -d "$target/schemas" ]]; then
            _run_user glib-compile-schemas "$target/schemas" 2>/dev/null || true
        fi

        printf '%s' "$sv"
        return 0
    done
    return 1
}

# ─── Install ───────────────────────────────────────────────────────────────

mapfile -t EXTENSIONS < <(grep -E '^[a-z0-9]' "$EXT_LIST")
log::info "Found ${#EXTENSIONS[@]} extensions in $EXT_LIST"

log::step "Installing extensions"

installed=()
skipped=()
for uuid in "${EXTENSIONS[@]}"; do
    if ver="$(_install_one "$uuid")"; then
        if [[ "$ver" == "$SHELL_PREV" ]]; then
            log::warn "  installed: $uuid (for GNOME $ver — may have glitches on $SHELL_MAJOR)"
        else
            log::ok   "  installed: $uuid (for GNOME $ver)"
        fi
        installed+=("$uuid")
    else
        log::warn "  failed: $uuid (no build for GNOME $SHELL_MAJOR / $SHELL_FULL / $SHELL_PREV)"
        skipped+=("$uuid")
    fi
done

# ─── Enable ────────────────────────────────────────────────────────────────

log::step "Enabling extensions"
for uuid in "${installed[@]}"; do
    if _run_session gnome-extensions enable "$uuid"; then
        log::ok "  enabled: $uuid"
    else
        log::warn "  could not enable now: $uuid (try after logout/login + re-run this script)"
    fi
done

# ─── Per-extension gsettings (sensible defaults) ────────────────────────────

log::step "Applying per-extension defaults"
_gset() {
    _run_session gsettings set "$@" 2>/dev/null \
        || log::warn "    gsettings set $* failed"
}

_has() { printf '%s\n' "${installed[@]}" | grep -q "$1"; }

if _has 'dash-to-dock@'; then
    log::info "  Dash to Dock"
    _gset org.gnome.shell.extensions.dash-to-dock dock-position           'BOTTOM'
    _gset org.gnome.shell.extensions.dash-to-dock dock-fixed              false
    _gset org.gnome.shell.extensions.dash-to-dock extend-height           false
    _gset org.gnome.shell.extensions.dash-to-dock intellihide             true
    _gset org.gnome.shell.extensions.dash-to-dock transparency-mode       'DYNAMIC'
    _gset org.gnome.shell.extensions.dash-to-dock dash-max-icon-size      40
    _gset org.gnome.shell.extensions.dash-to-dock click-action            'minimize-or-overview'
fi

if _has 'just-perfection'; then
    log::info "  Just Perfection"
    _gset org.gnome.shell.extensions.just-perfection activities-button    false
    _gset org.gnome.shell.extensions.just-perfection app-menu             false
    _gset org.gnome.shell.extensions.just-perfection panel-size           28
    _gset org.gnome.shell.extensions.just-perfection startup-status       0
fi

if _has 'blur-my-shell'; then
    log::info "  Blur My Shell"
    _gset org.gnome.shell.extensions.blur-my-shell.panel blur             true
    _gset org.gnome.shell.extensions.blur-my-shell.panel sigma            20
    _gset org.gnome.shell.extensions.blur-my-shell.overview blur          true
    _gset org.gnome.shell.extensions.blur-my-shell.applications blur      true
fi

if _has 'tilingshell@'; then
    log::info "  Tiling Shell"
    _gset org.gnome.shell.extensions.tilingshell inner-gaps               8
    _gset org.gnome.shell.extensions.tilingshell outer-gaps               8
    _gset org.gnome.shell.extensions.tilingshell snap-assist              true
fi

if _has 'caffeine@'; then
    log::info "  Caffeine"
    _gset org.gnome.shell.extensions.caffeine show-indicator              'always'
    _gset org.gnome.shell.extensions.caffeine toggle-state                false
fi

if _has 'clipboard-history'; then
    log::info "  Clipboard History"
    _gset org.gnome.shell.extensions.clipboard-history history-size       50
    _gset org.gnome.shell.extensions.clipboard-history paste-on-selection true
fi

# ─── Summary ───────────────────────────────────────────────────────────────

echo
log::ok "Installed ${#installed[@]} / ${#EXTENSIONS[@]} extensions"
if (( ${#skipped[@]} > 0 )); then
    log::warn "Skipped: ${skipped[*]}"
    log::info "Tip: open Extension Manager — it can find versions that this script's"
    log::info "shell-version probing missed (e.g. preview/beta builds)."
fi
log::info "Logout + login so GNOME Shell registers the new extensions."
log::info "Verify after relogin:  gnome-extensions list --enabled"
