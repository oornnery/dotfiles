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

## Plugins

`scripts/arch/dev/herdr.sh` installs this set pinned to commits and links the local
one. `plugins/` and `plugins.json` are runtime state (gitignored), so that script is
the reproducible record — `herdr plugin list` prints the same refs.

| Plugin | Source | Pinned | Bound to |
| ------ | ------ | ------ | -------- |
| herdr-navigator | `thanhdat77/herdr-navigator` | `8e90917` | `prefix+t`, `prefix+shift+t`, `prefix+l` |
| memex | `nicosuave/memex` | `a4f8152` | `prefix+m` session-history search |
| window-title-sync | `rjyo/herdr-window-title-sync` | `b07f114` | terminal tab titles |
| vim-herdr-navigation | `paulbkim-dev/vim-herdr-navigation` | `79679da` | `Alt+h/j/k/l` |

The last one is `herdr plugin link`ed from a clone under
`~/.local/share/herdr/plugins-src/` (override with `HERDR_PLUGIN_SRC_DIR`) because it
ships both the herdr action and the editor side. `jq` is required for the Vim
detection; without it the chord still moves herdr focus, it just stops crossing
Neovim split edges.

## Pane and split navigation

`Alt+h/j/k/l` runs the plugin action: if the focused pane's foreground process is
Vim/Neovim, the chord is forwarded as `Ctrl+h/j/k/l`, so Neovim moves between splits
and hands focus back to herdr at an edge. In any other pane herdr moves focus
directly. `Ctrl+h/j/k/l` is intentionally free — readline needs `Ctrl+L` and
`Ctrl+K`, and lazygit uses the same keys. The Neovim side is
`nvim/.config/nvim/lua/plugins/herdr.lua`, loaded on `VeryLazy` so it wins over the
plain window maps in `config/keymaps.lua`.

## Integrations

```bash
herdr integration install codex     # Codex agent state/session integration
herdr integration install opencode  # OpenCode session restore
herdr integration install pi        # Pi agent state
```

Supported agents out of the box: claude code, codex, opencode, pi, droid, grok,
github copilot CLI, cursor agent, devin, kimi code CLI, and more.

The setup script installs integrations only for CLIs that exist: Codex, OpenCode, Pi
and Claude Code. Check without restarting sessions:

```bash
herdr config check          # does config.toml validate?
herdr integration status    # which clients have lifecycle/session hooks
herdr plugin list           # installed plugins and their pinned refs
herdr agent list            # what herdr detects per pane
```

The configured OS notifications may not reach your Windows desktop over SSH.
For an in-terminal alternative, set `[ui.toast] delivery = "herdr"`. Compare editor
behavior outside Herdr before attributing a MobaXterm rendering issue to Neovim.

## Runtime files

These live in `~/.config/herdr/` at runtime and are **not** tracked in dotfiles:

| File                                                  | Purpose                      |
| ----------------------------------------------------- | ---------------------------- |
| `session.json`                                        | Session state (auto-saved)   |
| `session-history.json`                                | Pane screen history (opt-in) |
| `herdr.log` / `herdr-server.log` / `herdr-client.log` | Logs                         |
| `*.sock`                                              | Unix sockets                 |

## See also

- [herdr.dev](https://herdr.dev) — official site
- [github.com/ogulcancelik/herdr](https://github.com/ogulcancelik/herdr) — source (AGPL-3.0)
