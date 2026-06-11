# Manual

A reference for this dotfiles setup — Arch Linux, Hyprland/GNOME, AMD VAIO,
btrfs. Inspired by the [Omarchy Manual](https://learn.omacom.io/2/the-omarchy-manual)
but tailored to this hardware and workflow.

## Basics

- [Welcome](basics/01-welcome.md) — what this stack is and isn't
- [Getting Started](basics/02-getting-started.md) — fresh install → working desktop
- [Navigation](basics/03-navigation.md) — Hyprland keybindings cheat sheet
- [Hotkeys](basics/04-hotkeys.md) — full bindings catalog by category
- [Clipboard & History](basics/05-clipboard.md) — wl-clipboard + cliphist
- [Notices](basics/06-notices.md) — on-demand notify-send info
- [CLI Bootstrap](basics/07-cli.md) — `./scripts/arch/arch.sh` tour

## Applications

- [Terminal](applications/01-terminal.md) — alacritty + tmux + ghostty
- [Neovim](applications/02-neovim.md) — native base, lazy.nvim extras, mini.nvim alternative
- [Shell Tools](applications/03-shell-tools.md) — fzf, zoxide, eza, bat, fd, ripgrep
- [Shell Functions](applications/04-shell-functions.md) — `compress`, `iso2sd`, `fip`, …
- [TUIs](applications/05-tuis.md) — lazygit, lazydocker, btop, bluetui, impala
- [Zellij](applications/zellij.md) — terminal multiplexer (tmux replacement)
- [KTX](applications/ktx.md) — open-source context layer for data agents
- [Headroom](applications/headroom.md) — intelligent context compression for AI
- [Web Apps](applications/06-web-apps.md) — firefoxpwa + `web-app` wrapper
- [Gaming](applications/07-gaming.md) — Steam, wine, gamemode, mangohud
- [Windows VM](applications/08-windows-vm.md) — dockur/windows on Docker
- [bin/ scripts](applications/09-bin-scripts.md) — 24 helper scripts (screenshot, wallpaper, emoji, update, volume, magnify, theme, …)

## Configuration

- [Monitors](configuration/01-monitors.md) — `monitors.conf` + scaling hotkeys
- [Fingerprint](configuration/02-fingerprint.md) — fprintd setup + PAM
- [Prompt](configuration/03-prompt.md) — Starship config
- [Fonts](configuration/04-fonts.md) — Nerd Font + Noto
- [Dotfiles (Stow)](configuration/05-dotfiles.md) — workflow + new packages
- [Common Tweaks](configuration/06-tweaks.md) — power, snapper, swap, etc.
- [Theming](configuration/07-theming.md) — catppuccin-mocha / tokyo-night / catppuccin-latte
- [System stow](configuration/08-system-stow.md) — managing `/etc/` files via stow
- [GNOME rice](configuration/09-gnome-rice.md) — visual + WM-like workflow on top of GNOME
- [GNOME extensions](configuration/10-gnome-extensions.md) — curated list + install workflow
- [Waybar](configuration/11-waybar.md) — GNOME-inspired top bar layout + modules

## The Rest

- [Troubleshooting](rest/01-troubleshooting.md)
- [System Snapshots](rest/02-snapshots.md) — snapper
- [Security](rest/03-security.md) — ufw + ufw-docker + LUKS notes
- [FAQ](rest/04-faq.md)

## Cheatsheets

Per-tool quick references — paste-ready commands, no narrative.

### Shell & terminal

- [zsh](cheatsheets/zsh.md)
- [bash](cheatsheets/bash.md)
- [tmux](cheatsheets/tmux.md)
- [zellij](cheatsheets/zellij.md) — vim-flavored multiplexer
- [fastfetch](cheatsheets/fastfetch.md)

### File / text

- [eza](cheatsheets/eza.md) — `ls`/tree replacement
- [bat](cheatsheets/bat.md) — `cat` replacement
- [fzf](cheatsheets/fzf.md) — fuzzy finder
- [find](cheatsheets/find.md) — `find` + `fd`
- [grep](cheatsheets/grep.md) — `grep` + `ripgrep`

### Editor

- [neovim](cheatsheets/neovim.md)

### Version control

- [git](cheatsheets/git.md) — git + GitHub CLI

### Languages / runtimes

- [python](cheatsheets/python.md) — python + pip + uv
- [node](cheatsheets/node.md) — node + npm + pnpm + bun
- [go](cheatsheets/go.md)
- [rust](cheatsheets/rust.md)
- [build-tools](cheatsheets/build-tools.md) — make + cmake

### Packaging / system

- [stow](cheatsheets/stow.md)
- [apt](cheatsheets/apt.md) — apt + nala (for Debian/Ubuntu/WSL)

## See also

- [scripts/arch/arch.sh](../../scripts/arch/arch.sh) — interactive bootstrap launcher
- [scripts/arch/arch.conf](../../scripts/arch/arch.conf) — environment overrides
