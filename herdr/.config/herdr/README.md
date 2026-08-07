# Herdr — setup & plugin guide

Documentation of this machine's Herdr setup: what's installed, which plugins,
and how to use it. Tracked config lives in `~/dotfiles/herdr/.config/herdr/`
and is linked into `~/.config/herdr/` with GNU Stow.

## Overview

- **Herdr** — terminal-native agent multiplexer ("tmux for coding agents").
  Single Rust binary, no dependencies, mouse-first.
- **Plugin system** — executable workflow plugins (`herdr plugin install
  owner/repo`); each plugin gets its own config dir.
- **Runtime state** — plugin state lives in `~/.local/state/herdr/plugins/`,
  not in this repo. `release-notes.json` is stow-ignored.

## Installation

```sh
# Arch: AUR package
paru -S --needed herdr-bin

# Debian/other: download the release binary (no apt package)
curl -fsSL https://github.com/herdrdev/herdr/releases/latest/download/herdr-linux-$(uname -m) -o ~/.local/bin/herdr
chmod +x ~/.local/bin/herdr

# Everything at once (herdr + plugins + stow): from the dotfiles repo
bash herdr/setup.sh
```

Herdr ≥ 0.7.5 is required for the reviewr plugin.

## Plugin prerequisites

| Requirement | Why it is needed | Verify |
| ----------- | ---------------- | ------ |
| Bun | tab-smart-rename, sessionizer, window-title-sync plugins | `bun --version` |
| fzf | sessionizer project/worktree pickers | `command -v fzf` |
| `gh` | reviewr PR tab, ghzinga auth | `gh --version` |
| cargo | ghzinga binary (`cargo install ghzinga`), spreader build | `cargo --version` |
| zoxide | navigator zoxide source | `command -v zoxide` |

## Config files

| File | What it is |
| ---- | ---------- |
| `config.toml` | Main herdr config + `[[keys.command]]` plugin keybindings |
| `plugins/config/<id>/` | Per-plugin config (theme, scope, pickers) |
| `plugins/config/tab-smart-rename/provider.env` | Optional OpenAI-compatible key for AI tab renaming |
| `release-notes.json` | Herdr runtime file (stow-ignored, do not edit) |

## Plugins

| Plugin | What it does | Keybinding |
| ------ | ------------ | ---------- |
| `persiyanov/reviewr` | Code review pane: diff, line comments to agent, file viewer, fuzzy search, PR tab | `prefix+r` |
| `nicosuave/memex` | Local agent-session history search (Claude/Codex/OpenCode logs), BM25 + embeddings | `prefix+m` |
| `osolmaz/ghzinga` | GitHub PR/issue TUI (comment, merge, close, reopen); Ctrl-click GitHub URLs in herdr | URL click |
| `thanhdat77/herdr-navigator` | Fuzzy nav over workspaces/agents/projects/sessions/remotes/zoxide | `prefix+t`, `prefix+shift+t`, `prefix+l` |
| `yuk1ty/herdr-spreader` | Declarative YAML workspace layouts (tmuxinator-style) | `herdr-spreader.apply` action |
| `iurysza/herdr-tab-smart-rename` | Tab renaming (deterministic without API key, AI names with key) | `prefix+alt+t` |
| `andrewchng/herdr-sessionizer` | Fuzzy pickers for projects and git worktrees, workspace layout | `prefix+f`, `prefix+up` |
| `rjyo/herdr-window-title-sync` | Sync terminal window title to focused workspace/tab/agent | auto |

`herdr-file-viewer` was deliberately skipped — reviewr already includes a file
viewer, search, and find-in-file.

## Keybindings

All commands live in `~/.config/herdr/config.toml` under `[[keys.command]]`:

| Key | Command | Description |
| --- | ------- | ----------- |
| `prefix+t` | `herdr-navigator.open` | Navigate workspaces, sessions, projects |
| `prefix+shift+t` | `herdr-navigator.open-side` | Open navigator in side pane |
| `prefix+l` | `herdr-navigator.jump-back` | Jump back to previous workspace |
| `prefix+f` | `sessionizer.open` | Open project workspace |
| `prefix+up` | `sessionizer.worktree-open` | Open git worktree workspace |
| `prefix+r` | `persiyanov.reviewr.toggle` | Toggle code review pane |
| `prefix+m` | `nicosuave.memex.palette` | Search agent session history |
| `prefix+alt+t` | `tab-smart-rename.rename-now` | Rename current tab |

## Usage

```sh
herdr                 # launch or attach to server
herdr plugin list     # show installed plugins
herdr plugin install <owner>/<repo>   # add a plugin
```
