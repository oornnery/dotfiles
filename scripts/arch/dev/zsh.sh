#!/usr/bin/env bash
# dev/zsh.sh — zsh + Antigen + stow ~/dotfiles/zsh.
#
# Run as user, or `sudo bash ./dev/zsh.sh` (auto-drops priv for stow + Antigen).

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

USER_NAME="${USER_NAME:-${SUDO_USER:-$USER}}"

require_root

log::banner "Dev" "Zsh + Antigen"

log::info "Installing zsh, git and atuin (shell history database)"
sudo pacman -S --needed --noconfirm zsh git atuin

if ! id "$USER_NAME" >/dev/null 2>&1; then
    die "User $USER_NAME doesn't exist — run core/user.sh first"
fi

user_home="$(getent passwd "$USER_NAME" | cut -d: -f6)"
antigen_dir="$user_home/.antigen"

_run_user() {
    if [[ $EUID -eq 0 && "$USER_NAME" != "root" ]]; then
        sudo -u "$USER_NAME" -H "$@"
    else
        "$@"
    fi
}

# ─── Antigen ───────────────────────────────────────────────────────────────

log::step "Installing Antigen"
if [[ -d "$antigen_dir/.git" ]]; then
    log::skip "Antigen already installed at $antigen_dir"
else
    _run_user git clone --depth 1 https://github.com/zsh-users/antigen.git "$antigen_dir"
    log::ok "Antigen installed"
fi

# Plugins and the prompt theme are declared in zsh/.zshrc with `antigen bundle`
# and `antigen theme`. Antigen downloads them on the first shell start.

# ─── atuin (shell history database) ────────────────────────────────────────

log::step "Initializing atuin history DB"
if [[ -f "$user_home/.local/share/atuin/history.db" ]]; then
    log::skip "atuin DB already exists"
else
    log::info "Importing existing zsh history into atuin"
    _run_user atuin import auto 2>/dev/null \
        || log::warn "atuin import auto failed — run manually after first zsh start"
fi
# Login is optional (only needed for cross-machine sync — atuin.sh account).
# Not done here; user runs `atuin login -u <name>` manually if they want it.

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
