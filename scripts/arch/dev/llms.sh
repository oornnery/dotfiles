#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

USER_NAME="${USER_NAME:-${SUDO_USER:-$USER}}"

ENABLE_CLAUDE_CODE="${ENABLE_CLAUDE_CODE:-1}"
ENABLE_CODEX="${ENABLE_CODEX:-1}"
ENABLE_OLLAMA="${ENABLE_OLLAMA:-1}"
ENABLE_LM_STUDIO="${ENABLE_LM_STUDIO:-0}"

require_root

log::banner "Dev" "AI / LLM tools"

if ! id "$USER_NAME" >/dev/null 2>&1; then
    die "User $USER_NAME doesn't exist"
fi

if [[ $ENABLE_CLAUDE_CODE -eq 1 ]]; then
    log::step "Claude Code (Anthropic CLI)"
    if sudo -u "$USER_NAME" -H command -v claude >/dev/null 2>&1; then
        log::skip "claude already installed"
    else
        log::info "Installing via official installer"
        sudo -u "$USER_NAME" -H bash -c 'curl -fsSL https://claude.ai/install.sh | bash'
        log::ok "Claude Code installed (run 'claude login' to authenticate)"
    fi
fi

if [[ $ENABLE_CODEX -eq 1 ]]; then
    log::step "OpenAI Codex CLI"
    if sudo -u "$USER_NAME" -H command -v codex >/dev/null 2>&1; then
        log::skip "codex already installed"
    else
        if ! command -v npm >/dev/null 2>&1; then
            log::info "Installing nodejs + npm (codex prerequisite)"
            sudo pacman -S --needed --noconfirm nodejs npm
        fi
        log::info "Installing @openai/codex via npm (user-local)"
        sudo -u "$USER_NAME" -H bash -c '
            mkdir -p "$HOME/.local/npm"
            npm config set prefix "$HOME/.local/npm"
            npm install -g @openai/codex
        '
        log::ok "Codex installed in ~/.local/npm/bin (ensure it is in PATH)"
    fi
fi

if [[ $ENABLE_OLLAMA -eq 1 ]]; then
    log::step "Ollama (local LLM runtime)"
    if pacman -Qq ollama >/dev/null 2>&1; then
        log::skip "ollama already installed"
    else
        log::info "Installing ollama package"
        sudo pacman -S --needed --noconfirm ollama
        log::ok "Ollama installed"
    fi
    log::info "Enabling ollama.service"
    sudo systemctl enable --now ollama.service || log::warn "Could not enable ollama.service"
    log::info "Try: ollama pull llama3.2 && ollama run llama3.2"
fi

if [[ $ENABLE_LM_STUDIO -eq 1 ]]; then
    log::step "LM Studio (GUI for local LLMs)"
    if ! command -v paru >/dev/null 2>&1; then
        log::warn "paru not found — install via aur/paru.sh first"
    elif pacman -Qq lmstudio >/dev/null 2>&1 || pacman -Qq lmstudio-appimage >/dev/null 2>&1; then
        log::skip "LM Studio already installed"
    else
        log::info "Installing lmstudio via paru (AUR)"
        sudo -u "$USER_NAME" -H paru -S --needed --noconfirm lmstudio || \
            log::warn "AUR install failed — try 'lmstudio-appimage' manually"
    fi
fi

log::ok "AI/LLM setup completed"
