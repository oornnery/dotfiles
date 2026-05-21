#!/usr/bin/env bash
# dev/zsh.sh — zsh + Oh My Zsh + plugins + stow ~/dotfiles/zsh.
#
# Run as user, or `sudo bash ./dev/zsh.sh` (auto-drops priv for stow + OMZ).

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

USER_NAME="${USER_NAME:-${SUDO_USER:-$USER}}"

require_root

log::banner "Dev" "Zsh + Oh My Zsh"

log::info "Installing zsh + atuin (shell history database)"
sudo pacman -S --needed --noconfirm zsh atuin

if ! id "$USER_NAME" >/dev/null 2>&1; then
    die "User $USER_NAME doesn't exist — run core/user.sh first"
fi

user_home="$(getent passwd "$USER_NAME" | cut -d: -f6)"
omz_dir="$user_home/.oh-my-zsh"

_run_user() {
    if [[ $EUID -eq 0 && "$USER_NAME" != "root" ]]; then
        sudo -u "$USER_NAME" -H "$@"
    else
        "$@"
    fi
}

# ─── Oh My Zsh ─────────────────────────────────────────────────────────────

log::step "Installing Oh My Zsh"
if [[ -d "$omz_dir" ]]; then
    log::skip "Oh My Zsh already installed at $omz_dir"
else
    # shellcheck disable=SC2016  # outer bash receives this as a literal cmd
    _run_user env RUNZSH=no CHSH=no KEEP_ZSHRC=yes bash -c \
        'sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"'
    log::ok "Oh My Zsh installed"
fi

# ─── Plugins ───────────────────────────────────────────────────────────────

log::step "Installing Oh My Zsh plugins"
custom_dir="$omz_dir/custom/plugins"

declare -A plugins=(
    [zsh-autosuggestions]="https://github.com/zsh-users/zsh-autosuggestions"
    [fast-syntax-highlighting]="https://github.com/zdharma-continuum/fast-syntax-highlighting"
    [zsh-completions]="https://github.com/zsh-users/zsh-completions"
    [zsh-history-substring-search]="https://github.com/zsh-users/zsh-history-substring-search"
    [zsh-vi-mode]="https://github.com/jeffreytse/zsh-vi-mode"
    [fzf-tab]="https://github.com/Aloxaf/fzf-tab"
)

for plugin in "${!plugins[@]}"; do
    target="$custom_dir/$plugin"
    if [[ -d "$target" ]]; then
        log::skip "Plugin '$plugin' already installed"
    else
        log::info "Cloning $plugin"
        _run_user git clone --depth 1 "${plugins[$plugin]}" "$target"
    fi
done

# ─── Stow dotfiles ─────────────────────────────────────────────────────────

stow_safe zsh

# ─── Apply active theme ────────────────────────────────────────────────────

if [[ -n "${THEME:-}" ]] && command -v theme >/dev/null 2>&1; then
    _run_user theme set "$THEME" || log::warn "theme set failed"
fi

# ─── Default shell ─────────────────────────────────────────────────────────

current_shell="$(getent passwd "$USER_NAME" | cut -d: -f7)"
if [[ "$current_shell" != "/bin/zsh" ]]; then
    log::info "Changing default shell to /bin/zsh"
    sudo chsh -s /bin/zsh "$USER_NAME" || log::warn "chsh failed"
else
    log::skip "Default shell already /bin/zsh"
fi

log::ok "Zsh setup completed"
