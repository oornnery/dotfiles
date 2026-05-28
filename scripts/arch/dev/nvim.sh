#!/usr/bin/env bash
# dev/nvim.sh — neovim + stow the chosen distro.
#
# Picks between native (nvim/), mini.nvim (nvim.mini/) and LazyVim
# (nvim.lazy/) based on $NVIM_DISTRO. All target ~/.config/nvim, so they
# are mutually exclusive — switching is `NVIM_DISTRO=lazy ./nvim.sh`.

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

USER_NAME="${USER_NAME:-${SUDO_USER:-$USER}}"
NVIM_DISTRO="${NVIM_DISTRO:-mini}"

require_root

log::banner "Dev" "Neovim ($NVIM_DISTRO)"

log::info "Installing neovim"
sudo pacman -S --needed --noconfirm neovim

case "$NVIM_DISTRO" in
    native|plain|basic)
        pkg="nvim"
        ;;
    mini|minimal)
        pkg="nvim.mini"
        ;;
    lazy|lazyvim)
        pkg="nvim.lazy"
        ;;
    *)
        log::warn "Unknown NVIM_DISTRO=$NVIM_DISTRO; using mini"
        NVIM_DISTRO="mini"
        pkg="nvim.mini"
        ;;
esac

# Unstow the OTHER distro first to avoid both pointing at ~/.config/nvim.
user_home="$(getent passwd "$USER_NAME" | cut -d: -f6)"
_run_user() {
    if [[ $EUID -eq 0 && "$USER_NAME" != "root" ]]; then
        sudo -u "$USER_NAME" -H "$@"
    else
        "$@"
    fi
}

for other in nvim nvim.mini nvim.lazy; do
    [[ "$other" == "$pkg" ]] && continue
    if [[ -L "$user_home/.config/nvim" ]] \
       && _run_user readlink "$user_home/.config/nvim" 2>/dev/null \
            | grep -q "/$other/"; then
        log::info "Unstowing $other before stowing $pkg"
        _run_user stow -d "${DOTFILES_DIR:-$user_home/dotfiles}" \
            -t "$user_home" -D "$other" 2>/dev/null || true
    fi
done

stow_safe "$pkg"

# LazyVim auto-installs plugins on first launch. Native Neovim has no plugin
# manager, and mini.nvim keeps its own lightweight setup.

log::ok "Neovim ($NVIM_DISTRO) setup completed"
