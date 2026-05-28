#!/usr/bin/env bash
# dev/vim.sh — vim + selected Vim stow package.

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

USER_NAME="${USER_NAME:-${SUDO_USER:-$USER}}"
VIM_DISTRO="${VIM_DISTRO:-native}"

require_root

log::banner "Dev" "Vim"

log::info "Installing vim"
sudo pacman -S --needed --noconfirm vim

user_home="$(getent passwd "$USER_NAME" | cut -d: -f6)"

_run_user() {
    if [[ $EUID -eq 0 && "$USER_NAME" != "root" ]]; then
        sudo -u "$USER_NAME" -H "$@"
    else
        "$@"
    fi
}

case "$VIM_DISTRO" in
    native|plain|basic)
        pkg="vim"
        ;;
    plug|vim-plug|vimplug)
        pkg="vim.plug"
        ;;
    *)
        log::warn "Unknown VIM_DISTRO=$VIM_DISTRO; using native"
        VIM_DISTRO="native"
        pkg="vim"
        ;;
esac

# Both packages target ~/.vimrc, so unstow the inactive variant first.
for other in vim vim.plug; do
    [[ "$other" == "$pkg" ]] && continue
    if [[ -L "$user_home/.vimrc" ]] \
       && _run_user readlink "$user_home/.vimrc" 2>/dev/null \
            | grep -q "/$other/"; then
        log::info "Unstowing $other before stowing $pkg"
        _run_user stow -d "${DOTFILES_DIR:-$user_home/dotfiles}" \
            -t "$user_home" -D "$other" 2>/dev/null || true
    fi
done

stow_safe "$pkg"

if [[ "$pkg" == "vim.plug" ]]; then
    # vim-plug bootstrap (the .vimrc can auto-install it, but doing it upfront
    # avoids the first-launch race and downloads plugins eagerly).
    plug_vim="$user_home/.vim/autoload/plug.vim"

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
fi

log::ok "Vim ($VIM_DISTRO) setup completed"
