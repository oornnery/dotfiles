#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

require_root

log::banner "Dev" "Yazi file manager"

# yazi is already installed by dev/tools.sh — this module stows config.
# Run standalone: ./arch.sh dev/yazi

# ── Stow config ───────────────────────────────────────────────────────────────
stow_safe yazi

log::ok "Yazi config stowed"
