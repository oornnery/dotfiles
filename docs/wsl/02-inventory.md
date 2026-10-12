# Inventory

Regenerate the live version at any time:

```bash
dots wsl inventory
```

The report is safe to paste: credential and state paths are counted, never named, and
Windows user names are masked. This page is the curated reading of it.

## Packages

- **pacman:** 102 explicitly installed native packages (base system, shell tooling,
  languages, editors, network tools).
- **AUR / foreign:** `google-chrome`, `paru` (+ debug), `polylib`, `polylib-gmp`,
  `sngrep-bin`.
- **uv tools:** `headroom-ai`.
- **npm -g:** agent tooling (`codex-acp`, `pi-coding-agent`, `caveman-code`,
  `cavemem`, `impeccable`, `9router`, `openrtk`) plus a few libraries
  (`better-sqlite3`, `sql.js`, `systray2`, `@xenova/transformers`).
- **bun -g:** `@open-pencil/cli`. **pnpm -g** and **pipx** are empty.
- **cargo:** `ghzinga`, `rtk`, `rumdl`. **go:** `task`.
- **Node:** `fnm` has v22; `mise` is installed but manages nothing yet.
- **systemd (user):** only `9router.service` is enabled.

## Installed but not in `scripts/`

These are explicit pacman packages that no bootstrap script mentions, so a fresh install
would not bring them back:

| Packages                                                                           | Why they exist                    |
| ---------------------------------------------------------------------------------- | --------------------------------- |
| `baresip`, `bcg729`, `lksctp-tools`, `wireshark-cli`, `alsa-lib`, `opus`           | SIP and VoIP testing stack        |
| `cloudflared`                                                                      | Cloudflare tunnels                |
| `bubblewrap`                                                                       | sandbox used by coding agents     |
| `qt6-base`, `fontconfig`, `libglvnd`, `libxkbcommon-x11`, `xcb-util-cursor`, `gsl` | libraries pulled in for GUI tools |

Decision pending: move the first four rows into a script (`scripts/arch/dev/`) or accept
them as machine-local. The library row is almost certainly dependencies and does not
need tracking.

## Drift to clean up

- `pyright` is still installed, but Neovim now uses `ty` and Ruff for Python.
- `rtk` exists twice: as a cargo binary and as `openrtk` on npm.
- `README.md` said `wsl/.wslconfig`; the file is `windows/.wslconfig`.

## `$HOME`

| Kind                   | Examples                                                                                                                                              |
| ---------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------- |
| Stowed from the repo   | `.zshrc`, `.zshenv`, `.zprofile`, `.zlogin`, `.zsh_functions`, `.gitconfig`, `.tmux.conf`, `.vimrc`; `.config/nvim`, `yazi`, `zellij`, `helix`, `pet` |
| Tool state, only here  | agent and editor homes (`.claude`, `.codex`, `.pi`, `.cursor-server`, `.vscode-server`), toolchains (`.rustup`, `.cargo`, `.bun`, `.fnm`, `.dotnet`)  |
| `~/.config`, only here | `ags`, `fabric-shell`, `caddy`, `mako`, `walker`, `waybar`, `wofi`, `alacritty`, `herdr`, `rtk`, `systemd`, `starship.toml`, `workspace-cli`          |
| Credentials            | SSH, cloud CLIs, tokens, shell history: never versioned, never listed here                                                                            |
| Projects               | about 17 checkouts directly under `$HOME`                                                                                                             |

`herdr` is partly stowed (its `config.toml` links into the repo; plugins are local), and
`starship.toml` is a real file written by the theme tool, so neither is lost.

The Hyprland-era configs (`ags`, `mako`, `walker`, `waybar`, `wofi`, `fabric-shell`) are
unused on WSL. They are candidates for removal from this machine, not for stowing.
