#!/usr/bin/env bash
# core/firefoxpwa.sh — Firefox + firefoxpwa (PWA backend for `web-app`).
#
# firefoxpwa lives in the AUR and ships a Firefox extension + native helper
# that wraps any URL as a standalone PWA. `web-app` in ~/.local/bin/ is the
# thin user-friendly wrapper around `firefoxpwa site install/launch`.

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

USER_NAME="${USER_NAME:-${SUDO_USER:-$USER}}"

require_root

log::banner "Core" "Firefox PWA backend"

log::info "Installing firefox"
sudo pacman -S --needed --noconfirm firefox

if pacman -Qq firefoxpwa >/dev/null 2>&1; then
    log::skip "firefoxpwa already installed"
else
    if ! command -v paru >/dev/null 2>&1; then
        die "paru not installed — run core/paru.sh first (or aur-install firefoxpwa manually)"
    fi
    log::info "Installing firefoxpwa (AUR) as $USER_NAME"
    sudo -u "$USER_NAME" -H paru -S --needed --noconfirm firefoxpwa
fi

log::ok "Firefox + firefoxpwa installed"
log::info "Install the matching browser extension: https://addons.mozilla.org/firefox/addon/pwas-for-firefox/"
log::info "After the extension is set up, manage PWAs with:"
log::info "  web-app install <url> <name>    # install a site as a PWA"
log::info "  web-app launch <name>           # launch a PWA"
log::info "  web-app list                    # list installed PWAs"
