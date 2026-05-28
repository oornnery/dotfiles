#!/usr/bin/env bash
# dev/cli-tools.sh — modern Rust-based CLI replacements + quality-of-life tools.
#
# Run as user, or `sudo bash ./dev/cli-tools.sh` (auto-drops priv for AUR).

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

USER_NAME="${USER_NAME:-${SUDO_USER:-$USER}}"

ENABLE_CLI_ESSENTIAL="${ENABLE_CLI_ESSENTIAL:-1}"   # bottom/dust/duf/procs/sd/tealdeer/jless/git-delta
ENABLE_CLI_EXTRAS="${ENABLE_CLI_EXTRAS:-1}"          # xh/gum
ENABLE_CLI_AUR="${ENABLE_CLI_AUR:-1}"                # pay-respects/topgrade (AUR)

require_root

log::banner "Dev" "Modern CLI tools"

if ! id "$USER_NAME" >/dev/null 2>&1; then
    die "User $USER_NAME doesn't exist"
fi

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

# ─── Extras (xh / gum) ────────────────────────────────────────────────────

if [[ $ENABLE_CLI_EXTRAS -eq 1 ]]; then
    log::step "Extras: xh, gum"
    sudo pacman -S --needed --noconfirm xh gum
    log::info "forgit is loaded by Antigen from zsh/.zshrc"
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

log::ok "CLI tools setup completed"
