#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

require_root

log::banner "Dev" "Zellij terminal multiplexer"

# ── Install ───────────────────────────────────────────────────────────────────
sudo pacman -S --needed --noconfirm zellij

# ── Stow config ───────────────────────────────────────────────────────────────
stow_safe zellij

log::ok "Zellij setup completed"
