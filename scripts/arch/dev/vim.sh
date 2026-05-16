#!/usr/bin/env bash
# dev/vim.sh — vim + vim-plug autoinstall + stow ~/dotfiles/vim.

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

USER_NAME="${USER_NAME:-${SUDO_USER:-$USER}}"

require_root

log::banner "Dev" "Vim"

log::info "Installing vim"
sudo pacman -S --needed --noconfirm vim

stow_safe vim

# vim-plug bootstrap (the .vimrc auto-installs it, but doing it upfront
# avoids the first-launch race + downloads plugins eagerly).
user_home="$(getent passwd "$USER_NAME" | cut -d: -f6)"
plug_vim="$user_home/.vim/autoload/plug.vim"

_run_user() {
    if [[ $EUID -eq 0 && "$USER_NAME" != "root" ]]; then
        sudo -u "$USER_NAME" -H "$@"
    else
        "$@"
    fi
}

if [[ -f "$plug_vim" ]]; then
    log::skip "vim-plug already installed"
else
    log::info "Installing vim-plug"
    _run_user curl -fLo "$plug_vim" --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    log::ok "vim-plug installed"
fi

log::info "Installing plugins (vim +PlugInstall +qall)"
_run_user vim -es -u "$user_home/.vimrc" -i NONE -c "PlugInstall" -c "qall" || \
    log::warn "vim plugin install returned non-zero — run :PlugInstall manually"

log::ok "Vim setup completed"
