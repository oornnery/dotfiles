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

log::ok "CLI tools installed"
