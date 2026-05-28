#!/usr/bin/env bash
# dev/stow.sh — stow all relevant dotfiles packages in one shot.
#
# Per-tool modules (dev/{bash,tmux,vim,nvim,alacritty,git,zsh}.sh) stow
# their own packages too. This script is the catch-all for everything
# that doesn't have a dedicated module (or when you just want one go).

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../lib/detect.sh"

USER_NAME="${USER_NAME:-${SUDO_USER:-$USER}}"
VIM_DISTRO="${VIM_DISTRO:-native}"
NVIM_DISTRO="${NVIM_DISTRO:-mini}"

require_root
detect::system

log::banner "Dev" "Stow all dotfiles"

if ! id "$USER_NAME" >/dev/null 2>&1; then
    die "User $USER_NAME doesn't exist"
fi

if ! command -v stow >/dev/null 2>&1; then
    log::info "Installing stow"
    sudo pacman -S --needed --noconfirm stow
fi

# Packages to stow. Order doesn't matter; stow_safe is idempotent.
packages=(
    bash zsh tmux
    git editor fabric
    alacritty
    bin
    hyprland waybar wofi walker mako
    astal
)

# Vim: native config or vim-plug config — mutually exclusive.
case "$VIM_DISTRO" in
    native|plain|basic) packages+=(vim) ;;
    plug|vim-plug|vimplug) packages+=(vim.plug) ;;
    *)
        log::warn "Unknown VIM_DISTRO=$VIM_DISTRO; using native"
        VIM_DISTRO="native"
        packages+=(vim)
        ;;
esac

# Neovim: native config, mini.nvim or LazyVim — mutually exclusive.
case "$NVIM_DISTRO" in
    native|plain|basic) packages+=(nvim) ;;
    mini|minimal)       packages+=(nvim.mini) ;;
    lazy|lazyvim)       packages+=(nvim.lazy) ;;
    *)
        log::warn "Unknown NVIM_DISTRO=$NVIM_DISTRO; using mini"
        NVIM_DISTRO="mini"
        packages+=(nvim.mini)
        ;;
esac

[[ $IS_WSL -eq 1 ]] && packages+=(wsl)

user_home="$(getent passwd "$USER_NAME" | cut -d: -f6)"
dotfiles_dir="${DOTFILES_DIR:-$user_home/dotfiles}"

_run_user() {
    if [[ $EUID -eq 0 && "$USER_NAME" != "root" ]]; then
        sudo -u "$USER_NAME" -H "$@"
    else
        "$@"
    fi
}

is_selected_package() {
    local candidate="$1"
    local selected

    for selected in "${packages[@]}"; do
        [[ "$selected" == "$candidate" ]] && return 0
    done

    return 1
}

# Editor variants target the same files, so remove symlinks from inactive
# variants before stowing the selected packages.
for editor_pkg in vim vim.plug nvim nvim.mini nvim.lazy; do
    is_selected_package "$editor_pkg" && continue
    [[ -d "$dotfiles_dir/$editor_pkg" ]] || continue

    _run_user stow -d "$dotfiles_dir" -t "$user_home" -D "$editor_pkg" 2>/dev/null || true
done

for pkg in "${packages[@]}"; do
    stow_safe "$pkg" || log::warn "Stow failed for: $pkg"
done

# Apply active theme on top (writes ~/.config/<app>/theme.* files).
if [[ -n "${THEME:-}" ]] && command -v theme >/dev/null 2>&1; then
    if [[ $EUID -eq 0 && "$USER_NAME" != "root" ]]; then
        sudo -u "$USER_NAME" -H theme set "$THEME" || log::warn "theme set failed"
    else
        theme set "$THEME" || log::warn "theme set failed"
    fi
fi

log::ok "Stow completed"
