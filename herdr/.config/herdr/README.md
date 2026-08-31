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

# Everything at once (herdr + plugins + integrations + stow): from the dotfiles repo
bash herdr/setup.sh
```

The setup installs only the integrations used on this machine: Claude, Codex,
and OpenCode. Check them after a Herdr upgrade with `herdr integration status`;
rerunning `herdr/setup.sh` updates them.

## Plugin prerequisites

| Requirement | Why it is needed         | Verify              |
| ----------- | ------------------------ | ------------------- |
| Bun         | window-title-sync plugin | `bun --version`     |
| fzf         | navigator fuzzy picker   | `command -v fzf`    |
| zoxide      | navigator zoxide source  | `command -v zoxide` |

## Config files

| File                   | What it is                                                |
| ---------------------- | --------------------------------------------------------- |
| `config.toml`          | Main herdr config + `[[keys.command]]` plugin keybindings |
| `plugins/config/<id>/` | Per-plugin config (theme, scope, pickers)                 |
| `release-notes.json`   | Herdr runtime file (stow-ignored, do not edit)            |

## Plugins

| Plugin                         | What it does                                                                       | Keybinding                               |
| ------------------------------ | ---------------------------------------------------------------------------------- | ---------------------------------------- |
| `nicosuave/memex`              | Local agent-session history search (Claude/Codex/OpenCode logs), BM25 + embeddings | `prefix+m`                               |
| `thanhdat77/herdr-navigator`   | Fuzzy nav over workspaces/agents/projects/sessions/remotes/zoxide                  | `prefix+t`, `prefix+shift+t`, `prefix+l` |
| `rjyo/herdr-window-title-sync` | Sync terminal window title to focused workspace/tab/agent                          | auto                                     |

This intentionally small set covers navigation, session recall, and terminal titles.
GitHub review, declarative layouts, sessionizers, and AI tab naming stay outside Herdr;
the coding agents and existing CLI tools already cover those workflows.

## Keybindings

All commands live in `~/.config/herdr/config.toml` under `[[keys.command]]`:

| Key              | Command                     | Description                             |
| ---------------- | --------------------------- | --------------------------------------- |
| `prefix+t`       | `herdr-navigator.open`      | Navigate workspaces, sessions, projects |
| `prefix+shift+t` | `herdr-navigator.open-side` | Open navigator in side pane             |
| `prefix+l`       | `herdr-navigator.jump-back` | Jump back to previous workspace         |
| `prefix+m`       | `nicosuave.memex.palette`   | Search agent session history            |

## Usage

```sh
herdr                 # launch or attach to server
herdr plugin list     # show installed plugins
herdr plugin install <owner>/<repo>   # add a plugin
herdr integration status              # verify agent hooks
```
