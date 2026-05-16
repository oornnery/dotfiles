# Welcome

This is a personal Arch Linux dotfiles repo, with an opinionated bootstrap
script tuned for a single piece of hardware:

- VAIO laptop (Positivo Bahia) — chassis 10
- AMD CPU + AMD GPU
- btrfs root (no LUKS today)
- GNOME (default) + Hyprland (target)
- GDM as the login manager, greetd as a backup

If your hardware diverges, most modules check `detect::system` and skip
themselves; the ones that don't will print a warning. Nothing here is a
distro; it's a wiring diagram.

## What you get

- One script: `./scripts/arch/arch.sh` — an interactive TUI launcher with
  curated presets. Runs everything below in safe order.
- 4 module groups: `core/` (boot, hw, security, package infra),
  `desktop/` (GDM/Hyprland/GNOME/etc.), `dev/` (zsh, tools, languages,
  docker, llms), `game/` (Steam).
- A set of stow packages at the repo root — `nvim/`, `zsh/`, `tmux/`,
  `alacritty/`, `hyprland/`, `bin/`, `git/`, `editor/`, `fabric/`,
  `system/`. `dev/stow.sh` wires them into `~`.

## What you don't get

- A reproducible install image — that's archinstall's job; this is
  post-install.
- NVIDIA / Intel GPU support — those modules were removed because this
  hardware doesn't need them. Restore from git if you switch boxes.
- LUKS-rescue tooling — `core/luks.sh` was destructive and unused; gone.

## See also

- [Getting Started](02-getting-started.md) — fresh install → working desktop
- [Hotkeys](04-hotkeys.md) — Hyprland keybindings cheat sheet
- [CLI Bootstrap](07-cli.md) — how `arch.sh` is organised
