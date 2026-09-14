#!/usr/bin/env bash
set -euo pipefail

# User-side installer for Claude Code/Codex/OpenCode; configuration comes only from this repo.
# The Arch system bootstrap remains scripts/arch/dev/llms.sh.
repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
if [[ $EUID -eq 0 ]]; then
    echo "Run as the target user, not root; use scripts/arch/dev/llms.sh for system setup." >&2
    exit 1
fi

# The Claude desktop app ships no Linux CLI: under WSL it drives shells from the
# Windows side, so `claude` is absent and /plugin, /hooks and /config never open.
if [[ ${ENABLE_CLAUDE:-1} == 1 ]] && ! command -v claude >/dev/null 2>&1; then
    command -v npm >/dev/null || { echo "Install Node.js/npm first." >&2; exit 1; }
    npm install --global --prefix "$HOME/.local" @anthropic-ai/claude-code
fi
if [[ ${ENABLE_CODEX:-1} == 1 ]] && ! command -v codex >/dev/null 2>&1; then
    command -v npm >/dev/null || { echo "Install Node.js/npm first." >&2; exit 1; }
    npm install --global --prefix "$HOME/.local" @openai/codex
fi
if [[ ${ENABLE_OPENCODE:-1} == 1 ]] && ! command -v opencode >/dev/null 2>&1; then
    curl -fsSL https://opencode.ai/install | bash
fi
if [[ ${ENABLE_CAVEMEM:-1} == 1 ]] && ! command -v cavemem >/dev/null 2>&1; then
    command -v npm >/dev/null || { echo "Install Node.js/npm first." >&2; exit 1; }
    npm install --global --prefix "$HOME/.local" cavemem@0.2.1
fi

bash "$repo_dir/scripts/ai-setup.sh" --apply
echo "Configuration applied. Restart the clients; authenticate with codex login and OpenCode /connect."
