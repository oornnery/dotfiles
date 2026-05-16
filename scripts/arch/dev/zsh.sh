#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../lib/detect.sh"

USER_NAME="${USER_NAME:-${SUDO_USER:-$USER}}"
DOTFILES_DIR="${DOTFILES_DIR:-/home/$USER_NAME/dotfiles}"

require_root
detect::system

log::banner "Dev" "Shell (zsh + Oh My Zsh)"

# Shell only. CLI/TUI tools live in dev/tools.sh, editors in dev/{vim,nvim}.sh,
# terminals in dev/alacritty.sh and desktop/hyprland.sh.
PKGS=(zsh)

log::info "Installing shell packages"
sudo pacman -S --needed --noconfirm "${PKGS[@]}"

if ! id "$USER_NAME" >/dev/null 2>&1; then
    die "User $USER_NAME doesn't exist — run system/user.sh first"
fi

user_home="$(getent passwd "$USER_NAME" | cut -d: -f6)"
omz_dir="$user_home/.oh-my-zsh"

log::step "Installing Oh My Zsh (as $USER_NAME)"

if [[ -d "$omz_dir" ]]; then
    log::skip "Oh My Zsh already installed at $omz_dir"
else
    sudo -u "$USER_NAME" -H bash -c '
        RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    '
    log::ok "Oh My Zsh installed"
fi

log::step "Installing Oh My Zsh plugins"

custom_dir="$omz_dir/custom/plugins"

declare -A plugins=(
    [zsh-autosuggestions]="https://github.com/zsh-users/zsh-autosuggestions"
    [zsh-syntax-highlighting]="https://github.com/zsh-users/zsh-syntax-highlighting"
    [zsh-completions]="https://github.com/zsh-users/zsh-completions"
    [fzf-tab]="https://github.com/Aloxaf/fzf-tab"
)

for plugin in "${!plugins[@]}"; do
    target="$custom_dir/$plugin"
    if [[ -d "$target" ]]; then
        log::skip "Plugin '$plugin' already installed"
    else
        log::info "Cloning $plugin"
        sudo -u "$USER_NAME" -H git clone --depth 1 "${plugins[$plugin]}" "$target"
        log::ok "Installed $plugin"
    fi
done

log::step "Stowing zsh dotfiles"

if [[ ! -d "$DOTFILES_DIR/zsh" ]]; then
    log::warn "Stow source missing: $DOTFILES_DIR/zsh — skipping"
else
    if ! command -v stow >/dev/null 2>&1; then
        sudo pacman -S --needed --noconfirm stow
    fi
    sudo -u "$USER_NAME" -H stow -d "$DOTFILES_DIR" -t "$user_home" -R zsh \
        || log::warn "stow zsh failed (file conflict? back up existing ~/.zshrc etc.)"
    log::ok "zsh dotfiles stowed"
fi

current_shell="$(getent passwd "$USER_NAME" | cut -d: -f7)"
if [[ "$current_shell" != "/bin/zsh" ]]; then
    log::info "Changing default shell to /bin/zsh"
    sudo chsh -s /bin/zsh "$USER_NAME" || log::warn "chsh failed"
else
    log::skip "Default shell already /bin/zsh"
fi

log::ok "Shell setup completed"
