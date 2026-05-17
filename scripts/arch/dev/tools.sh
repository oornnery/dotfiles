#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

require_root

log::banner "Dev" "Modern CLI tools"

PKGS=(
    # multiplexer + editor (config in dev/{tmux,nvim}.sh)
    tmux neovim

    # search + replace + view
    ripgrep fd fzf
    jq yq htmlq xmlstarlet
    bat eza zoxide plocate

    # shell history + prompt + dev mgmt
    atuin starship
    mise direnv

    # TUIs / runners
    lazygit yazi
    tealdeer usage gum

    # system stats
    procs dust duf sd xh bottom gping doggo tokei
    fastfetch btop

    # forges
    github-cli glab

    # network + parsing
    whois inetutils socat
    tree-sitter-cli

    # OCR (used by ~/.local/bin/ocr)
    tesseract tesseract-data-eng tesseract-data-por

    # screen recording (used by ~/.local/bin/record)
    wf-recorder
)

sudo pacman -S --needed --noconfirm "${PKGS[@]}"

# AUR-only TUIs (best-effort — skip if paru/AUR unavailable).
USER_NAME="${USER_NAME:-${SUDO_USER:-$USER}}"
if sudo -u "$USER_NAME" -H bash -c 'command -v paru' >/dev/null 2>&1; then
    log::info "Installing AUR TUIs (pacsea, cliamp)"
    for aur_pkg in pacsea cliamp; do
        if sudo -u "$USER_NAME" -H paru -S --needed --noconfirm "$aur_pkg"; then
            log::ok "  $aur_pkg"
        else
            log::warn "  $aur_pkg failed — try '$aur_pkg-bin' or '$aur_pkg-git' manually"
        fi
    done
else
    log::warn "paru not found — skipping AUR TUIs (pacsea, cliamp). Run core/paru.sh first."
fi

log::ok "CLI tools installed"
