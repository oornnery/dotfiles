# AI tools

The old Claude, Codex, OpenCode and Pi setup is in `ai/`, mapped in
`ai/README.md`. Nothing there is linked yet.

| Task | Command |
| ---- | ------- |
| Claude Code | `claude` |
| Codex | `codex` |
| OpenCode | `opencode` |
| Link one setup after reviewing it | `stow --no-folding -d ~/dotfiles/ai -t ~ claude` |

API keys go in `~/.config/ai/env` (see `ai/env.example`). It is sourced by
`env.sh` and never tracked.
