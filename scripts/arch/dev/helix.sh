#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

require_root

log::banner "Dev" "Helix editor + LSPs"

USER_NAME="${USER_NAME:-${SUDO_USER:-$USER}}"

# ── Helix ─────────────────────────────────────────────────────────────────────
sudo pacman -S --needed --noconfirm helix taplo

# ── LSP packages (npm global) ─────────────────────────────────────────────────
log::info "Installing npm LSPs (typescript, html, css, json)"
sudo -u "$USER_NAME" npm install -g \
    typescript-language-server \
    vscode-langservers-extracted \
    @tailwindcss/language-server 2>/dev/null || log::warn "npm LSPs partial"

# ── rust-analyzer ─────────────────────────────────────────────────────────────
if command -v rustup >/dev/null 2>&1; then
    log::info "Installing rust-analyzer via rustup"
    sudo -u "$USER_NAME" rustup component add rust-analyzer 2>/dev/null || \
        log::warn "rustup component add failed — try: pacman -S rust-analyzer"
elif pacman -Si rust-analyzer >/dev/null 2>&1; then
    sudo pacman -S --needed --noconfirm rust-analyzer
fi

# ── Stow config ───────────────────────────────────────────────────────────────
stow_safe helix

log::ok "Helix setup completed"
