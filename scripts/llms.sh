#!/usr/bin/env bash
set -euo pipefail

# AI coding tools for Arch / WSL.

USER_NAME="${USER_NAME:-${SUDO_USER:-${USER}}}"

ENABLE_CLAUDE_CODE="${ENABLE_CLAUDE_CODE:-1}"
ENABLE_CODEX="${ENABLE_CODEX:-1}"
ENABLE_OPENCODE="${ENABLE_OPENCODE:-1}"
ENABLE_RTK="${ENABLE_RTK:-1}"
ENABLE_CAVEMAN="${ENABLE_CAVEMAN:-1}"
ENABLE_CAVEKIT="${ENABLE_CAVEKIT:-1}"
ENABLE_CLAUDE_MEM="${ENABLE_CLAUDE_MEM:-${ENABLE_CAVEMEM:-1}}"
ENABLE_SECURITY_GUIDANCE="${ENABLE_SECURITY_GUIDANCE:-1}"
ENABLE_FRONTEND_DESIGN="${ENABLE_FRONTEND_DESIGN:-1}"
ENABLE_IMPECCABLE="${ENABLE_IMPECCABLE:-1}"
ENABLE_PYDANTIC_SKILLS="${ENABLE_PYDANTIC_SKILLS:-1}"
ENABLE_FASTAPI_SKILL="${ENABLE_FASTAPI_SKILL:-1}"

SKILL_AGENTS="${SKILL_AGENTS:-opencode,codex,claude-code}"
PYDANTIC_SKILLS_REPO="${PYDANTIC_SKILLS_REPO:-pydantic/skills}"
FASTAPI_SKILL_REPO="${FASTAPI_SKILL_REPO:-microsoft/skills}"
FASTAPI_SKILL_NAME="${FASTAPI_SKILL_NAME:-fastapi-router-py}"

log() { printf '\n==> %s\n' "$*"; }
warn() { printf 'WARN: %s\n' "$*" >&2; }

root() {
  if [[ $EUID -eq 0 ]]; then "$@"; else sudo "$@"; fi
}

u() {
  local cmd="$1"
  local path='export PATH="$HOME/.local/bin:$HOME/.local/npm/bin:$HOME/.cargo/bin:$HOME/.codex/bin:$HOME/.opencode/bin:$PATH";'

  if [[ "$(id -un)" == "$USER_NAME" ]]; then
    bash -lc "$path $cmd"
  else
    sudo -u "$USER_NAME" -H bash -lc "$path $cmd"
  fi
}

has() {
  u "command -v $1 >/dev/null 2>&1"
}

node() {
  command -v pacman >/dev/null 2>&1 && root pacman -S --needed --noconfirm nodejs npm
  has npm || { warn "npm not found"; return 1; }
  u 'mkdir -p "$HOME/.local/npm/bin" && npm config set prefix "$HOME/.local/npm" >/dev/null'
}

skill() {
  local repo="$1" skill="${2:-}" agents agent cmd

  node || return 0
  IFS=',' read -r -a agents <<<"$SKILL_AGENTS"

  for agent in "${agents[@]}"; do
    agent="${agent// /}"
    [[ -z "$agent" ]] && continue

    cmd="npx -y skills add $repo -a $agent"
    [[ -n "$skill" ]] && cmd="npx -y skills add $repo --skill $skill -a $agent"

    u "$cmd" || warn "skill failed: $repo${skill:+/$skill} for $agent"
  done
}

claude_plugin() {
  local plugin="$1" marketplace="${2:-}"

  has claude || { warn "claude not found; skipping $plugin"; return 0; }
  [[ -n "$marketplace" ]] && u "claude plugin marketplace add $marketplace >/dev/null 2>&1 || true"
  u "claude plugin install $plugin" || warn "plugin failed: $plugin"
}

id "$USER_NAME" >/dev/null 2>&1 || { warn "user not found: $USER_NAME"; exit 1; }

if command -v pacman >/dev/null 2>&1; then
  log "Base requirements"
  root pacman -S --needed --noconfirm ca-certificates curl git
fi

if [[ "$ENABLE_OPENCODE" -eq 1 ]]; then
  log "OpenCode CLI"
  has opencode || u 'curl -fsSL https://opencode.ai/install | bash'
fi

if [[ "$ENABLE_CLAUDE_CODE" -eq 1 ]]; then
  log "Claude Code CLI"
  has claude || u 'curl -fsSL https://claude.ai/install.sh | bash'
fi

if [[ "$ENABLE_CODEX" -eq 1 ]]; then
  log "OpenAI Codex CLI"
  has codex || u 'curl -fsSL https://chatgpt.com/codex/install.sh | sh' || true
  has codex || { node && u 'npm install -g @openai/codex@latest'; } || warn "codex install failed"
fi

if [[ "$ENABLE_RTK" -eq 1 ]]; then
  log "RTK"
  has rtk || u 'curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/master/install.sh | sh'
  has rtk && u 'rtk init --global' || warn "rtk global init failed"
  has rtk && u 'rtk init -g --codex' || warn "rtk codex init failed"
fi

if [[ "$ENABLE_SECURITY_GUIDANCE" -eq 1 ]]; then
  log "Claude security-guidance"
  claude_plugin "security-guidance@claude-plugins-official"
fi

if [[ "$ENABLE_FRONTEND_DESIGN" -eq 1 ]]; then
  log "Claude frontend-design"
  claude_plugin "frontend-design@claude-plugins-official"
fi

if [[ "$ENABLE_CAVEMAN" -eq 1 ]]; then
  log "Caveman"
  skill "JuliusBrussee/caveman"
fi

if [[ "$ENABLE_CAVEKIT" -eq 1 ]]; then
  log "Cavekit"
  skill "JuliusBrussee/cavekit"
  claude_plugin "ck@cavekit-marketplace" "JuliusBrussee/cavekit"
fi

if [[ "$ENABLE_CLAUDE_MEM" -eq 1 ]]; then
  log "Claude-Mem"
  node && u 'npx -y claude-mem install --ide claude-code' || warn "claude-mem Claude setup failed"
  has opencode && u 'npx -y claude-mem install --ide opencode' || true
  has codex && u 'npx -y claude-mem install --ide codex-cli' || true
fi

if [[ "$ENABLE_IMPECCABLE" -eq 1 ]]; then
  log "Impeccable"
  skill "pbakaus/impeccable"
  claude_plugin "impeccable@impeccable" "pbakaus/impeccable"
fi

if [[ "$ENABLE_PYDANTIC_SKILLS" -eq 1 ]]; then
  log "Pydantic / Pydantic AI"
  claude_plugin "pydantic-ai@claude-plugins-official"
  claude_plugin "ai@pydantic-skills" "$PYDANTIC_SKILLS_REPO"
  claude_plugin "logfire@pydantic-skills" "$PYDANTIC_SKILLS_REPO"
  skill "$PYDANTIC_SKILLS_REPO"
  has codex && u "codex plugin marketplace add $PYDANTIC_SKILLS_REPO" || true
fi

if [[ "$ENABLE_FASTAPI_SKILL" -eq 1 ]]; then
  log "FastAPI skill"
  skill "$FASTAPI_SKILL_REPO" "$FASTAPI_SKILL_NAME"
fi

log "AI/LLM setup completed"
