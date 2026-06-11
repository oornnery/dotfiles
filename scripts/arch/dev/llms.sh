#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

USER_NAME="${USER_NAME:-${SUDO_USER:-$USER}}"

ENABLE_CLAUDE_CODE="${ENABLE_CLAUDE_CODE:-1}"
ENABLE_CODEX="${ENABLE_CODEX:-1}"
ENABLE_OPENCODE="${ENABLE_OPENCODE:-1}"
ENABLE_ANTIGRAVITY="${ENABLE_ANTIGRAVITY:-1}"
ENABLE_OLLAMA="${ENABLE_OLLAMA:-1}"
ENABLE_LM_STUDIO="${ENABLE_LM_STUDIO:-0}"
ENABLE_RTK="${ENABLE_RTK:-1}"
ENABLE_CAVEMAN="${ENABLE_CAVEMAN:-1}"
ENABLE_CAVEKIT="${ENABLE_CAVEKIT:-1}"
ENABLE_CAVEMEM="${ENABLE_CAVEMEM:-1}"
ENABLE_AGENTS="${ENABLE_AGENTS:-1}"
ENABLE_AI_WAYBAR="${ENABLE_AI_WAYBAR:-1}"
AGENTS_REPO="${AGENTS_REPO:-oornnery/.agents}"

require_root

log::banner "Dev" "AI / LLM tools"

if ! id "$USER_NAME" >/dev/null 2>&1; then
    die "User $USER_NAME doesn't exist"
fi

if [[ $ENABLE_CLAUDE_CODE -eq 1 ]]; then
    log::step "Claude Code (Anthropic CLI)"
    if sudo -u "$USER_NAME" -H bash -c 'command -v "$1"' _ claude >/dev/null 2>&1; then
        log::skip "claude already installed"
    else
        log::info "Installing via official installer"
        sudo -u "$USER_NAME" -H bash -c 'curl -fsSL https://claude.ai/install.sh | bash'
        log::ok "Claude Code installed (run 'claude login' to authenticate)"
    fi
fi

if [[ $ENABLE_CODEX -eq 1 ]]; then
    log::step "OpenAI Codex CLI"
    if sudo -u "$USER_NAME" -H bash -c 'command -v "$1"' _ codex >/dev/null 2>&1; then
        log::skip "codex already installed"
    elif command -v paru >/dev/null 2>&1; then
        log::info "Installing openai-codex from AUR (paru)"
        sudo -u "$USER_NAME" -H paru -S --needed --noconfirm openai-codex \
            || log::warn "AUR install failed; falling back to npm"
    fi

    # Fallback: npm install if codex still missing and paru wasn't there / failed.
    if ! sudo -u "$USER_NAME" -H bash -c 'command -v "$1"' _ codex >/dev/null 2>&1; then
        if ! command -v npm >/dev/null 2>&1; then
            log::info "Installing nodejs + npm (codex prerequisite)"
            sudo pacman -S --needed --noconfirm nodejs npm
        fi
        log::info "Installing @openai/codex via npm (user-local fallback)"
        sudo -u "$USER_NAME" -H bash -c '
            mkdir -p "$HOME/.local/npm"
            npm config set prefix "$HOME/.local/npm"
            npm install -g @openai/codex
        '
        log::ok "Codex installed in ~/.local/npm/bin (ensure it is in PATH)"
    fi
fi

if [[ $ENABLE_OPENCODE -eq 1 ]]; then
    log::step "OpenCode CLI"
    if sudo -u "$USER_NAME" -H bash -c 'command -v "$1"' _ opencode >/dev/null 2>&1; then
        log::skip "opencode already installed"
    else
        log::info "Installing via official installer"
        sudo -u "$USER_NAME" -H bash -c 'curl -fsSL https://opencode.ai/install | bash' || \
            log::warn "OpenCode install failed (check network / installer)"
        log::ok "OpenCode installed (run 'opencode', then /connect and /models)"
    fi
fi

if [[ $ENABLE_ANTIGRAVITY -eq 1 ]]; then
    log::step "Antigravity CLI (Google AI agent CLI)"
    if sudo -u "$USER_NAME" -H bash -c 'command -v "$1"' _ antigravity >/dev/null 2>&1; then
        log::skip "antigravity already installed"
    else
        log::info "Installing via official installer (antigravity.google)"
        sudo -u "$USER_NAME" -H bash -c \
            'curl -fsSL https://antigravity.google/cli/install.sh | bash' || \
            log::warn "Antigravity install failed (check network / installer)"
        log::ok "Antigravity installed (run 'antigravity --help' to verify)"
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

if [[ $ENABLE_RTK -eq 1 ]]; then
    log::step "RTK (prompt optimizer)"
    if sudo -u "$USER_NAME" -H bash -c 'command -v "$1"' _ rtk >/dev/null 2>&1; then
        log::skip "rtk already installed"
    else
        log::info "Installing via official installer"
        sudo -u "$USER_NAME" -H bash -c '
            curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | sh
        '
        log::info "Initializing global config"
        sudo -u "$USER_NAME" -H bash -c 'rtk init --global' || \
            log::warn "rtk init --global failed (rerun manually after PATH refresh)"
        log::ok "RTK installed (rerun 'rtk init --global' if PATH wasn't picked up)"
    fi
fi

user_home="$(getent passwd "$USER_NAME" | cut -d: -f6)"

# Helper: ensure Node.js + npm before installing any of the caveman tools.
_ensure_node() {
    if ! command -v node >/dev/null 2>&1; then
        log::info "Installing nodejs + npm (Caveman ecosystem needs Node ≥18)"
        sudo pacman -S --needed --noconfirm nodejs npm
    fi
}

# ─── Caveman ecosystem (JuliusBrussee) ─────────────────────────────────────
# Three complementary tools for token-efficient AI agent workflows:
#   caveman → compress OUTPUT (what the agent says) via "caveman language"
#   cavekit → spec-driven dev (SPEC.md + /ck:spec /ck:build /ck:check)
#   cavemem → persistent memory across sessions (SQLite + MCP)

if [[ $ENABLE_CAVEMAN -eq 1 ]]; then
    log::step "Caveman (output token compression, ~65%)"
    if [[ -d "$user_home/.claude/skills/caveman" ]]; then
        log::skip "caveman skill already installed"
    else
        _ensure_node
        log::info "Installing via official installer"
        sudo -u "$USER_NAME" -H bash -c \
            'curl -fsSL https://raw.githubusercontent.com/JuliusBrussee/caveman/main/install.sh | bash' \
            || log::warn "caveman install failed (check network)"
        log::ok "caveman installed — trigger with /caveman in Claude/Codex/Gemini"
    fi
fi

if [[ $ENABLE_CAVEKIT -eq 1 ]]; then
    log::step "Cavekit (spec-driven dev for Claude Code)"
    if [[ -d "$user_home/.claude/plugins/cavekit" ]]; then
        log::skip "cavekit plugin already installed"
    else
        _ensure_node
        log::info "Installing via git clone → ~/.claude/plugins/cavekit"
        sudo -u "$USER_NAME" -H bash -c '
            mkdir -p "$HOME/.claude/plugins"
            git clone --depth 1 https://github.com/JuliusBrussee/cavekit.git "$HOME/.claude/plugins/cavekit"
        ' || log::warn "cavekit clone failed"
        log::ok "cavekit installed — commands: /ck:spec /ck:build /ck:check"
    fi
fi

if [[ $ENABLE_CAVEMEM -eq 1 ]]; then
    log::step "Cavemem (cross-session persistent memory + MCP)"
    if sudo -u "$USER_NAME" -H bash -c 'command -v "$1"' _ cavemem >/dev/null 2>&1; then
        log::skip "cavemem already installed"
    else
        _ensure_node
        log::info "Installing globally via npm"
        sudo -u "$USER_NAME" -H bash -c '
            mkdir -p "$HOME/.local/npm"
            npm config set prefix "$HOME/.local/npm"
            npm install -g cavemem
        ' || log::warn "cavemem npm install failed"
        log::ok "cavemem installed (viewer: cavemem viewer → http://localhost:37777)"
    fi

    if sudo -u "$USER_NAME" -H bash -c 'command -v "$1"' _ cavemem >/dev/null 2>&1; then
        log::info "Registering Claude Code hooks + MCP"
        sudo -u "$USER_NAME" -H bash -c 'cavemem install' \
            || log::warn "cavemem install hooks failed — run 'cavemem install' manually"
        log::info "Registering OpenCode hooks + MCP"
        sudo -u "$USER_NAME" -H bash -c 'cavemem install --ide opencode' \
            || log::warn "cavemem OpenCode hooks failed — run 'cavemem install --ide opencode' manually"
    fi
fi

if [[ $ENABLE_AGENTS -eq 1 ]]; then
    log::step "Custom agent skills (~/.agents)"
    user_home="$(getent passwd "$USER_NAME" | cut -d: -f6)"
    target="$user_home/.agents"

    if [[ -d "$target/.git" ]]; then
        log::info "Updating $target"
        sudo -u "$USER_NAME" -H git -C "$target" pull --ff-only || \
            log::warn "git pull failed (local changes? resolve manually)"
    elif [[ -d "$target" ]]; then
        log::warn "$target exists but is not a git repo — leaving alone"
    else
        if ! sudo -u "$USER_NAME" -H bash -c 'command -v "$1"' _ gh >/dev/null 2>&1; then
            log::info "Installing github-cli (gh) — needed to clone the agents repo"
            sudo pacman -S --needed --noconfirm github-cli
        fi
        log::info "Cloning $AGENTS_REPO → $target"
        sudo -u "$USER_NAME" -H gh repo clone "$AGENTS_REPO" "$target" || \
            log::warn "gh clone failed — run 'gh auth login' then retry"
    fi
fi

if [[ $ENABLE_AI_WAYBAR -eq 1 ]]; then
    log::step "waybar-ai-usage (Claude / Codex / Copilot monitor)"
    if ! pacman -Qq waybar >/dev/null 2>&1; then
        log::skip "waybar not installed — install desktop/hyprland first"
    elif ! command -v paru >/dev/null 2>&1; then
        log::warn "paru not found — install core/paru.sh first"
    elif pacman -Qq waybar-ai-usage >/dev/null 2>&1; then
        log::skip "waybar-ai-usage already installed"
    else
        log::info "Installing waybar-ai-usage via paru (AUR)"
        sudo -u "$USER_NAME" -H paru -S --needed --noconfirm waybar-ai-usage \
            || log::warn "AUR install failed"
        log::info "Waybar config already references custom/ai-usage — reload waybar"
    fi
fi

log::ok "AI/LLM setup completed"
