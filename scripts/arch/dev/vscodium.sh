#!/usr/bin/env bash
# dev/vscodium.sh — VSCodium (FOSS VS Code) + marketplace + features.
#
# Shares settings.json/keybindings/snippets with the upstream `code`
# (vscode) by symlinking ~/.config/VSCodium/User → ~/.config/Code/User.
# So `vscode/` stow package serves both editors.

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

USER_NAME="${USER_NAME:-${SUDO_USER:-$USER}}"

require_root

log::banner "Dev" "VSCodium"

if ! command -v paru >/dev/null 2>&1; then
    die "paru not installed — run core/paru.sh first"
fi

log::info "Installing vscodium + vscodium-marketplace + vscodium-features (AUR)"
sudo -u "$USER_NAME" -H paru -S --needed --noconfirm \
    vscodium vscodium-marketplace vscodium-features

# Stow the shared user config — same dir vscode would use.
stow_safe vscode

# Bridge VSCodium → Code/User so both editors share settings.
user_home="$(getent passwd "$USER_NAME" | cut -d: -f6)"

_as_user() {
    if [[ $EUID -eq 0 && "$USER_NAME" != "root" ]]; then
        sudo -u "$USER_NAME" -H "$@"
    else
        "$@"
    fi
}

vscodium_dir="$user_home/.config/VSCodium"
code_user="$user_home/.config/Code/User"

if [[ ! -d "$code_user" ]]; then
    log::warn "$code_user missing — stow vscode failed?"
else
    _as_user mkdir -p "$vscodium_dir"
    if [[ -L "$vscodium_dir/User" ]] \
       && [[ "$(readlink "$vscodium_dir/User")" == "$code_user" ]]; then
        log::skip "VSCodium/User already linked to Code/User"
    else
        # If a real dir exists, back it up first.
        if [[ -e "$vscodium_dir/User" && ! -L "$vscodium_dir/User" ]]; then
            ts="$(date +%Y%m%d%H%M%S)"
            _as_user mv "$vscodium_dir/User" "$vscodium_dir/User.bak.$ts"
            log::info "Backed up existing $vscodium_dir/User"
        fi
        _as_user ln -sfn "$code_user" "$vscodium_dir/User"
        log::ok "Linked $vscodium_dir/User → $code_user"
    fi
fi

# Bulk-install extensions from editor/Code/.vscode/extensions.json if present.
ext_file="${DOTFILES_DIR:-$user_home/dotfiles}/editor/Code/.vscode/extensions.json"
if [[ -f "$ext_file" ]] && command -v codium >/dev/null 2>&1; then
    log::step "Installing extension recommendations into VSCodium"
    while IFS= read -r ext; do
        [[ -z "$ext" ]] && continue
        _as_user codium --install-extension "$ext" 2>/dev/null \
            || log::warn "  ✗ $ext (may not exist on Open VSX)"
    done < <(grep -v '//' "$ext_file" | jq -r '.recommendations[]?' 2>/dev/null)
fi

log::ok "VSCodium installed and wired"
log::info "Launch with: codium"
