#!/usr/bin/env bash
# dev/git.sh — git + github-cli + stow ~/dotfiles/git.

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

USER_NAME="${USER_NAME:-${SUDO_USER:-$USER}}"

require_root

log::banner "Dev" "Git + GitHub CLI"

log::info "Installing git, github-cli, git-delta"
sudo pacman -S --needed --noconfirm git github-cli git-delta

stow_safe git

# Friendly nudge to auth gh and set up signing if missing.
user_home="$(getent passwd "$USER_NAME" | cut -d: -f6)"
if [[ ! -f "$user_home/.config/gh/hosts.yml" ]]; then
    log::info "Authenticate gh with: gh auth login"
fi

if [[ ! -f "$user_home/.ssh/id_ed25519" ]]; then
    log::info "No SSH key found — run scripts/arch/core/user.sh to generate one"
fi

log::ok "Git setup completed"
