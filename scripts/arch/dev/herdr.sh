#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

USER_NAME="${USER_NAME:-${SUDO_USER:-$USER}}"
ENABLE_HERDR="${ENABLE_HERDR:-1}"

require_root

log::banner "Dev" "Herdr — agent multiplexer"

if [[ $ENABLE_HERDR -ne 1 ]]; then
    log::skip "Herdr disabled (ENABLE_HERDR=0)"
    exit 0
fi

if ! id "$USER_NAME" >/dev/null 2>&1; then
    die "User $USER_NAME doesn't exist"
fi

log::step "Installing Herdr"

if sudo -u "$USER_NAME" -H bash -c 'command -v "$1"' _ herdr >/dev/null 2>&1; then
    log::skip "herdr already installed ($(sudo -u "$USER_NAME" -H bash -c 'herdr --version 2>/dev/null || echo unknown'))"
else
    log::info "Installing via official installer"
    sudo -u "$USER_NAME" -H bash -c 'curl -fsSL https://herdr.dev/install.sh | sh' || \
        log::warn "Herdr install failed (check network / installer)"
    log::ok "Herdr installed (run 'herdr' to launch)"
fi

log::step "Stowing herdr config"
stow_safe herdr

log::ok "Herdr setup completed"