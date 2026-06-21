# Herdr

[Herdr](https://herdr.dev) is a terminal-native agent multiplexer — think "tmux
for coding agents." Single Rust binary, no dependencies, runs in any terminal
(including SSH).

## What it does

- **Persistent panes** — detach/reattach, agents keep running
- **Agent-aware sidebar** — shows per-agent state (blocked/working/done/idle)
- **Mouse-first** — click panes, drag borders, right-click menus
- **Plugin system** — executable workflow plugins, any language
- **18 built-in themes** — catppuccin, tokyo-night, gruvbox, etc.

## Installation

```bash
# Bootstrap module (idempotent)
./scripts/arch/arch.sh dev/herdr

# Or manual
curl -fsSL https://herdr.dev/install.sh | sh
```

## Config

Config lives at `~/.config/herdr/config.toml` and is managed via the `herdr/`
stow package. Default config is minimal — herdr works fine without one.

```bash
# Generate default config
herdr --default-config > ~/.config/herdr/config.toml
```

## Usage

```bash
herdr              # launch or attach to server
herdr --help       # full CLI reference
```

Inside herdr:
- `prefix+q` — detach (prefix defaults to `Ctrl+b`)
- Click panes, drag borders, right-click for menus
- Sidebar shows agent state across all workspaces

## Integrations

```bash
herdr integration install claude    # Claude Code session restore
herdr integration install opencode  # OpenCode session restore
```

Supported agents out of the box: claude code, codex, opencode, pi, droid, grok,
github copilot CLI, cursor agent, devin, kimi code CLI, and more.

## Runtime files

These live in `~/.config/herdr/` at runtime and are **not** tracked in dotfiles:

| File | Purpose |
|---|---|
| `session.json` | Session state (auto-saved) |
| `session-history.json` | Pane screen history (opt-in) |
| `herdr.log` / `herdr-server.log` / `herdr-client.log` | Logs |
| `*.sock` | Unix sockets |

## See also

- [herdr.dev](https://herdr.dev) — official site
- [github.com/ogulcancelik/herdr](https://github.com/ogulcancelik/herdr) — source (AGPL-3.0)