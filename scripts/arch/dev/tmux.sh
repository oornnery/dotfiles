#!/usr/bin/env bash
# dev/tmux.sh — tmux + tpm autoinstall + stow ~/dotfiles/tmux.

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

USER_NAME="${USER_NAME:-${SUDO_USER:-$USER}}"

require_root

log::banner "Dev" "Tmux"

log::info "Installing tmux"
sudo pacman -S --needed --noconfirm tmux

stow_safe tmux

# Auto-install tpm so plugins are ready next time tmux starts.
user_home="$(getent passwd "$USER_NAME" | cut -d: -f6)"
tpm_dir="$user_home/.tmux/plugins/tpm"

if [[ -d "$tpm_dir" ]]; then
    log::skip "tpm already installed at $tpm_dir"
else
    log::info "Cloning tpm"
    if [[ $EUID -eq 0 && "$USER_NAME" != "root" ]]; then
        sudo -u "$USER_NAME" -H git clone --depth 1 https://github.com/tmux-plugins/tpm "$tpm_dir"
    else
        git clone --depth 1 https://github.com/tmux-plugins/tpm "$tpm_dir"
    fi
    log::ok "tpm installed (open tmux and press prefix+I to install plugins)"
fi

log::ok "Tmux setup completed"
