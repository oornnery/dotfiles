# Herdr Cheatsheet

Terminal workspace manager for coding agents — [herdr.dev](https://herdr.dev).
Config: `herdr/.config/herdr/config.toml` (stowed to `~/.config/herdr/config.toml`).
Prefix is `Ctrl+b`, written `prefix+` below. `prefix+?` lists every **active**
binding live; `/` filters it.

## Five to learn first

| Bind             | Action                            |
| ---------------- | --------------------------------- |
| `prefix+c`       | New tab                           |
| `prefix+v`       | Split right                       |
| `prefix+-`       | Split down                        |
| `prefix+h/j/k/l` | Move between panes                |
| `prefix+w`       | Workspace navigation              |
| `prefix+q`       | Detach — everything keeps running |

## Panes, tabs, workspaces

| Bind                    | Action                                                 |
| ----------------------- | ------------------------------------------------------ |
| `prefix+z`              | Zoom focused pane                                      |
| `prefix+x`              | Close pane                                             |
| `prefix+shift+h/j/k/l`  | Swap panes                                             |
| `prefix+r`              | Resize mode                                            |
| `prefix+[`              | Copy mode (`h/j/k/l`, `v` select, `y` copy, `q` leave) |
| `prefix+n` / `prefix+p` | Next / previous tab                                    |
| `prefix+1..9`           | Jump to tab                                            |
| `prefix+shift+t`        | Rename tab                                             |
| `prefix+shift+x`        | Close tab                                              |
| `prefix+shift+n`        | New workspace                                          |
| `prefix+shift+w`        | Rename workspace                                       |
| `prefix+shift+d`        | Close workspace                                        |
| `prefix+g`              | Goto picker                                            |
| `prefix+b`              | Toggle sidebar                                         |

Rebind the prefix with `[keys] prefix = "ctrl+a"`. The docs' safe chord family for
prefix-free bindings is `ctrl+alt+…`; plain `alt+…` is free on Linux but gets
composed on macOS.

## Pane and split navigation (this setup)

`Alt+h/j/k/l` runs the `vim-herdr-navigation` plugin action instead of moving
herdr focus directly:

- focused pane runs Vim/Neovim → the chord is forwarded as `Ctrl+h/j/k/l`, so
  Neovim moves between **splits** and hands focus back to herdr at a split edge;
- any other pane → herdr moves focus.

`Ctrl+h/j/k/l` is deliberately **not** bound: it would swallow readline's
`Ctrl+L` (clear) and `Ctrl+K` (kill line) in every shell pane. Inside Neovim the
plain `Ctrl+h/j/k/l` window maps still work.

Set `HERDR_NAV_PASSTHROUGH_RE` where you launch herdr if a TUI should keep the
chord itself, e.g. `export HERDR_NAV_PASSTHROUGH_RE='^(lazygit|vi-sql)$'`.

## Plugin actions bound in config.toml

| Bind             | Action                                                          |
| ---------------- | --------------------------------------------------------------- |
| `prefix+t`       | `herdr-navigator.open` — workspaces, agents, projects, sessions |
| `prefix+shift+t` | `herdr-navigator.open-side` — same, in a side pane              |
| `prefix+l`       | `herdr-navigator.jump-back` — previous workspace                |
| `prefix+m`       | `nicosuave.memex.palette` — search agent session history        |
| `Alt+h/j/k/l`    | `vim-herdr-navigation.left/down/up/right`                       |

## CLI checks

```bash
herdr                            # attach (never nested inside a pane)
herdr status                     # client + server summary
herdr config check               # config.toml validates?
herdr server reload-config       # apply config edits without restarting panes
herdr plugin list                # installed plugins and their pinned refs
herdr plugin action list --plugin vim-herdr-navigation
herdr integration status         # which agents have lifecycle/session hooks
herdr agent list                 # what herdr detects per pane
herdr agent explain <target> --json   # why a pane got that state
herdr --default-config           # every config key with its default
```

## Agent states

`working` · `blocked` (waiting for input) · `done` · `idle` · `unknown`, shown per
pane border and rolled up per workspace in the sidebar. Integrations add lifecycle
state and native session restore: this setup installs **codex**, **opencode** and
**pi**; `claude` is installed only when the CLI exists. `scripts/arch/dev/herdr.sh`
does it all, including pinned plugin installs.

## Runtime files (never committed)

`session.json`, `session-history.json`, `*.log`, `*.sock`, `plugins/`,
`plugins.json`, `*.bak.*` — all gitignored. Logs live in `~/.config/herdr/`.

## See also

- [herdr.dev/docs/keyboard](https://herdr.dev/docs/keyboard/) — full default keymap
- [Applications → Herdr](../applications/herdr.md) — setup, plugins, integrations
- [TUIs](../applications/05-tuis.md) — lazygit/lazydocker inside panes
