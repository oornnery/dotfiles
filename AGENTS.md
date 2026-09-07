# Dotfiles

Personal Linux dotfiles and post-install scripts, primarily managed with GNU Stow.
Root directories such as zsh/, nvim/, codex/, opencode/ and agents/ are Stow packages.
Only opencode/ is the active OpenCode package.

## Repository map

- scripts/arch/: modular Arch bootstrap; arch.conf selects tools and hardware options.
- scripts/arch/lib/common.sh: logging, privilege checks and Stow helpers.
- scripts/arch/lib/detect.sh: hardware/VM/WSL detection.
- scripts/win/: PowerShell bootstrap; keep Windows changes scoped and report if untested.
- bin/.local/bin/dots: dispatcher; bin/.local/lib/dots/: standalone command modules.
- docs/: user-facing manuals; docs/configuration/ai-agents.md: AI setup and model routing.
- agents/.agents/skills/: shared skills; Impeccable is vendored at a pinned revision.
- codex/.codex/ and opencode/.config/opencode/: client-specific adapters.

## Conventions

Preserve unrelated changes. User configuration may be symlinked directly into this
checkout, so edits can affect the next client session immediately. Never commit
credentials, runtime databases, caches or machine-installed binaries.

Keep scripts idempotent and compatible with the existing common.sh helpers.
Dots modules compose through `dots <group>`, not by sourcing each other.
Preserve hardware detection and WSL/VM guards; do not generalize machine-specific
defaults without inspecting arch.conf and detection code.

System Stow packages (gdm, greetd, iwd, wsl, zram) can target /etc; never apply them
as part of an AI-configuration change. Native nvim/ is the active editor package;
other editor variants are separate choices.

## Checks

Use bash -n on changed Bash scripts, ShellCheck when installed, and rumdl on changed
Markdown. AI config validation: `python3 scripts/validate-ai.py` (PyYAML required).
Safe link preview: `bash scripts/ai-setup.sh --dry-run`.
Do not run system bootstraps merely to validate edits.
