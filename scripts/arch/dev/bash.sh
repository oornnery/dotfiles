#!/usr/bin/env bash
# dev/bash.sh — bash + bash-completion + stow ~/dotfiles/bash.
#
# Standalone: ./scripts/arch/dev/bash.sh
# As root:    sudo bash scripts/arch/dev/bash.sh   (auto-drops priv for stow)

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

require_root

log::banner "Dev" "Bash"

log::info "Installing bash + bash-completion"
sudo pacman -S --needed --noconfirm bash bash-completion

stow_safe bash

log::ok "Bash setup completed"
