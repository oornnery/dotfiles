#!/usr/bin/env bash
# dev/cli-tools.sh — modern Rust-based CLI replacements + quality-of-life tools.
#
# Run as user, or `sudo bash ./dev/cli-tools.sh` (auto-drops priv for AUR).

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

USER_NAME="${USER_NAME:-${SUDO_USER:-$USER}}"

ENABLE_CLI_ESSENTIAL="${ENABLE_CLI_ESSENTIAL:-1}"   # bottom/dust/duf/procs/sd/tealdeer/jless/git-delta
ENABLE_CLI_EXTRAS="${ENABLE_CLI_EXTRAS:-1}"          # xh/gum/forgit
ENABLE_CLI_AUR="${ENABLE_CLI_AUR:-1}"                # pay-respects/topgrade (AUR)
ENABLE_ZSH_DEFER="${ENABLE_ZSH_DEFER:-1}"            # async plugin loader

require_root

log::banner "Dev" "Modern CLI tools"

if ! id "$USER_NAME" >/dev/null 2>&1; then
    die "User $USER_NAME doesn't exist"
fi

user_home="$(getent passwd "$USER_NAME" | cut -d: -f6)"

# ─── Essential pack (all in extra/community) ───────────────────────────────

if [[ $ENABLE_CLI_ESSENTIAL -eq 1 ]]; then
    log::step "Essential modern CLI replacements"
    sudo pacman -S --needed --noconfirm \
        bottom dust duf procs sd tealdeer jless git-delta
    log::info "tealdeer cache update (run as user)"
    sudo -u "$USER_NAME" -H tldr --update 2>/dev/null \
        || log::warn "tldr --update failed (transient; run manually if needed)"
    log::ok "Essential CLI tools installed"
fi

# ─── Extras (xh / gum / forgit) ───────────────────────────────────────────

if [[ $ENABLE_CLI_EXTRAS -eq 1 ]]; then
    log::step "Extras: xh, gum (forgit comes via OMZ plugin clone)"
    sudo pacman -S --needed --noconfirm xh gum
    # forgit: OMZ-compatible plugin, clone into custom plugins
    forgit_dir="$user_home/.oh-my-zsh/custom/plugins/forgit"
    if [[ -d "$forgit_dir" ]]; then
        log::skip "forgit plugin already cloned"
    elif [[ -d "$user_home/.oh-my-zsh" ]]; then
        log::info "Cloning forgit plugin → $forgit_dir"
        sudo -u "$USER_NAME" -H git clone --depth 1 \
            https://github.com/wfxr/forgit "$forgit_dir" \
            || log::warn "forgit clone failed"
    else
        log::warn "Oh My Zsh not installed; skipping forgit"
    fi
    log::ok "Extras installed"
fi

# ─── AUR (pay-respects, topgrade) ─────────────────────────────────────────

if [[ $ENABLE_CLI_AUR -eq 1 ]]; then
    log::step "AUR: pay-respects + topgrade"
    if ! command -v paru >/dev/null 2>&1; then
        log::warn "paru not found — install core/paru.sh first"
    else
        sudo -u "$USER_NAME" -H paru -S --needed --noconfirm \
            pay-respects topgrade || log::warn "AUR install failed"
        log::ok "pay-respects + topgrade installed"
    fi
fi

# ─── zsh-defer (async plugin loader) ──────────────────────────────────────

if [[ $ENABLE_ZSH_DEFER -eq 1 ]]; then
    log::step "zsh-defer (async plugin loader — fast prompt startup)"
    defer_dir="$user_home/.oh-my-zsh/custom/plugins/zsh-defer"
    if [[ -d "$defer_dir" ]]; then
        log::skip "zsh-defer already cloned"
    elif [[ -d "$user_home/.oh-my-zsh" ]]; then
        log::info "Cloning zsh-defer → $defer_dir"
        sudo -u "$USER_NAME" -H git clone --depth 1 \
            https://github.com/romkatv/zsh-defer "$defer_dir" \
            || log::warn "zsh-defer clone failed"
        log::ok "zsh-defer installed — restart shell to use deferred inits"
    else
        log::warn "Oh My Zsh not installed; skipping zsh-defer"
    fi
fi

log::ok "CLI tools setup completed"
