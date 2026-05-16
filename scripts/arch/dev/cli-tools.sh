#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

require_root

log::banner "Dev" "Modern CLI tools"

sudo pacman -S --needed --noconfirm \
    tmux \
    ripgrep fd fzf \
    jq yq htmlq xmlstarlet \
    bat eza zoxide plocate \
    atuin starship \
    lazygit yazi \
    tealdeer usage gum \
    procs dust duf sd xh bottom gping doggo tokei \
    github-cli glab \
    mise direnv \
    whois inetutils socat \
    tree-sitter-cli

log::ok "CLI tools installed"
