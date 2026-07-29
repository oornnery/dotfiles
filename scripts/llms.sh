#!/usr/bin/env bash
set -euo pipefail

# AI coding tools for Arch / WSL. Always (re)installs; disable a tool with its
# ENABLE_* flag, e.g. `ENABLE_RTK=0 ./scripts/llms.sh`.

USER_NAME="${USER_NAME:-${SUDO_USER:-${USER}}}"

ENABLE_CLAUDE_CODE="${ENABLE_CLAUDE_CODE:-1}"
ENABLE_CODEX="${ENABLE_CODEX:-1}"
ENABLE_OPENCODE="${ENABLE_OPENCODE:-1}"
ENABLE_RTK="${ENABLE_RTK:-1}"
ENABLE_CAVEMAN="${ENABLE_CAVEMAN:-1}"
ENABLE_CAVEKIT="${ENABLE_CAVEKIT:-1}"
ENABLE_CAVEMEM="${ENABLE_CAVEMEM:-1}"
ENABLE_SECURITY_GUIDANCE="${ENABLE_SECURITY_GUIDANCE:-1}"
ENABLE_FRONTEND_DESIGN="${ENABLE_FRONTEND_DESIGN:-1}"
ENABLE_IMPECCABLE="${ENABLE_IMPECCABLE:-1}"
ENABLE_PYDANTIC_SKILLS="${ENABLE_PYDANTIC_SKILLS:-1}"
ENABLE_FASTAPI_SKILL="${ENABLE_FASTAPI_SKILL:-1}"

SKILL_AGENTS="${SKILL_AGENTS:-opencode,codex,claude-code}"
PYDANTIC_SKILLS_REPO="${PYDANTIC_SKILLS_REPO:-pydantic/skills}"
FASTAPI_SKILL_REPO="${FASTAPI_SKILL_REPO:-microsoft/skills}"
FASTAPI_SKILL_NAME="${FASTAPI_SKILL_NAME:-fastapi-router-py}"
NODE_VERSION="${NODE_VERSION:-22.23.0}"

log()  { printf '\n==> %s\n' "$*"; }
warn() { printf 'WARN: %s\n' "$*" >&2; }

# Run as root (sudo only if we aren't already).
root() { if [[ $EUID -eq 0 ]]; then "$@"; else sudo "$@"; fi; }

# Run a command as $USER_NAME with the user's install dirs on PATH.
u() {
  local path='export PATH="$HOME/.fnm:$HOME/.fnm/aliases/default/bin:$HOME/.npm-global/bin:$HOME/.local/bin:$HOME/.cargo/bin:$HOME/.codex/bin:$HOME/.opencode/bin:$PATH";'
  if [[ "$(id -un)" == "$USER_NAME" ]]; then
    bash -lc "$path $1"
  else
    sudo -u "$USER_NAME" -H bash -lc "$path $1"
  fi
}

has() { u "command -v $1 >/dev/null 2>&1"; }

# Ensure Node/npm — only does real work the first time it's called.
_NODE_READY=0
node() {
  [[ "$_NODE_READY" == 1 ]] && return 0
  has fnm || u 'curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell'
  u "fnm install '$NODE_VERSION' && fnm default '$NODE_VERSION'"
  has npm || { warn "npm not found after fnm setup"; return 1; }
  u 'mkdir -p "$HOME/.npm-global/bin" && npm config set prefix "$HOME/.npm-global" >/dev/null'
  _NODE_READY=1
}

# Install a skills.sh repo to every agent in one non-interactive shot:
# -y/-g skip the confirm+scope prompts, --skill '*' grabs all skills in a repo,
# and --agent is variadic so it must stay last.
skill() {
  local repo="$1" name="${2:-}"
  node || return 0
  u "npx -y skills add '$repo' -y -g --skill '${name:-*}' --agent ${SKILL_AGENTS//,/ } </dev/null" \
    || warn "skill failed: $repo${name:+/$name}"
}

claude_plugin() {
  local plugin="$1" marketplace="${2:-}"
  has claude || { warn "claude not found; skipping $plugin"; return 0; }
  [[ -n "$marketplace" ]] && u "claude plugin marketplace add $marketplace >/dev/null 2>&1 || true"
  u "claude plugin install $plugin" || warn "plugin failed: $plugin"
}

# run <enabled> <label> "<cmds>" — skip unless enabled, else log then run.
run() {
  [[ "$1" == 1 ]] || return 0
  log "$2"
  eval "$3" || warn "$2 failed"
}

id "$USER_NAME" >/dev/null 2>&1 || { warn "user not found: $USER_NAME"; exit 1; }

if command -v pacman >/dev/null 2>&1; then
  log "Base requirements"
  root pacman -S --needed --noconfirm ca-certificates curl git
fi

run "$ENABLE_OPENCODE"          "OpenCode CLI" \
  "u 'curl -fsSL https://opencode.ai/install | bash' || warn 'opencode install failed'"

run "$ENABLE_CLAUDE_CODE"       "Claude Code CLI" \
  "u 'curl -fsSL https://claude.ai/install.sh | bash' || warn 'claude install failed'"

run "$ENABLE_CODEX"             "OpenAI Codex CLI" \
  "u 'curl -fsSL https://chatgpt.com/codex/install.sh | sh' \
     || { node && u 'npm install -g @openai/codex@latest'; } \
     || warn 'codex install failed'"

run "$ENABLE_RTK"               "RTK" \
  "u 'curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/master/install.sh | sh' || warn 'rtk install failed'; \
   u 'rtk init --global'  || warn 'rtk global init failed'; \
   u 'rtk init -g --codex' || warn 'rtk codex init failed'"

run "$ENABLE_SECURITY_GUIDANCE" "Claude security-guidance" \
  "claude_plugin security-guidance@claude-plugins-official"

run "$ENABLE_FRONTEND_DESIGN"   "Claude frontend-design" \
  "claude_plugin frontend-design@claude-plugins-official"

run "$ENABLE_CAVEMAN"           "Caveman" \
  "skill JuliusBrussee/caveman"

run "$ENABLE_CAVEKIT"           "Cavekit" \
  "skill JuliusBrussee/cavekit; claude_plugin ck@cavekit-marketplace JuliusBrussee/cavekit"

run "$ENABLE_CAVEMEM"           "Cavemem" \
  "node && u 'npm install -g cavemem@0.2.1 @xenova/transformers@2.17.2' || warn 'cavemem install failed'; \
   has claude && u 'claude mcp remove --scope user cavemem >/dev/null 2>&1 || true; claude mcp add --scope user cavemem -- \"$HOME/.fnm/aliases/default/bin/node\" \"$HOME/.npm-global/lib/node_modules/cavemem/dist/index.js\" mcp' || true; \
   has codex && u 'codex mcp remove cavemem >/dev/null 2>&1 || true; codex mcp add cavemem -- \"$HOME/.fnm/aliases/default/bin/node\" \"$HOME/.npm-global/lib/node_modules/cavemem/dist/index.js\" mcp' || true"

run "$ENABLE_IMPECCABLE"        "Impeccable" \
  "skill pbakaus/impeccable; claude_plugin impeccable@impeccable pbakaus/impeccable"

run "$ENABLE_PYDANTIC_SKILLS"   "Pydantic / Pydantic AI" \
  "claude_plugin pydantic-ai@claude-plugins-official; \
   claude_plugin ai@pydantic-skills $PYDANTIC_SKILLS_REPO; \
   claude_plugin logfire@pydantic-skills $PYDANTIC_SKILLS_REPO; \
   skill $PYDANTIC_SKILLS_REPO; \
   has codex && u \"codex plugin marketplace add $PYDANTIC_SKILLS_REPO\" || true"

run "$ENABLE_FASTAPI_SKILL"     "FastAPI skill" \
  "skill $FASTAPI_SKILL_REPO $FASTAPI_SKILL_NAME"

log "AI/LLM setup completed"
