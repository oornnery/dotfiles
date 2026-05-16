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
- [Neovim](applications/02-neovim.md) — mini.nvim + LazyVim alternative
- [Shell Tools](applications/03-shell-tools.md) — fzf, zoxide, eza, bat, fd, ripgrep
- [Shell Functions](applications/04-shell-functions.md) — `compress`, `iso2sd`, `fip`, …
- [TUIs](applications/05-tuis.md) — lazygit, lazydocker, btop, bluetui, impala
- [Web Apps](applications/06-web-apps.md) — firefoxpwa + `web-app` wrapper
- [Gaming](applications/07-gaming.md) — Steam, wine, gamemode, mangohud
- [Windows VM](applications/08-windows-vm.md) — dockur/windows on Docker

## Configuration

- [Monitors](configuration/01-monitors.md) — `monitors.conf` + scaling hotkeys
- [Fingerprint](configuration/02-fingerprint.md) — fprintd setup + PAM
- [Prompt](configuration/03-prompt.md) — Starship config
- [Fonts](configuration/04-fonts.md) — Nerd Font + Noto
- [Dotfiles (Stow)](configuration/05-dotfiles.md) — workflow + new packages
- [Common Tweaks](configuration/06-tweaks.md) — power, snapper, swap, etc.

## The Rest

- [Troubleshooting](rest/01-troubleshooting.md)
- [System Snapshots](rest/02-snapshots.md) — snapper
- [Security](rest/03-security.md) — ufw + ufw-docker + LUKS notes
- [FAQ](rest/04-faq.md)

## See also

- [docs/](../) — tool-specific cheatsheets (eza, fzf, bat, …)
- [scripts/arch/arch.sh](../../scripts/arch/arch.sh) — interactive bootstrap launcher
- [scripts/arch/arch.conf](../../scripts/arch/arch.conf) — environment overrides
