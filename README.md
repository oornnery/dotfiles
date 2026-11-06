# dotfiles

Personal setup for Arch Linux on WSL, ready to go back to Arch on the desktop. Simple
scripts that just run, with every step safe to repeat. Start with `dots`.

## New machine

```bash
git clone <this repo> ~/dotfiles
stow --no-folding -d ~/dotfiles -t ~ dots
dots setup
```

## How it works

Each folder with dotfiles inside is a GNU Stow package, linked into `$HOME` file by
file. `~/.config/dots/packages` lists what is linked on this machine.

| Path | What it is |
| ---- | ---------- |
| `dots/` | The `dots` command: one script per subcommand in `.local/lib/dots/` |
| `shell/`, `zsh/`, `bash/` | Shell config; `shell/` is shared by zsh and bash |
| `helix/`, `nvim/`, `vim/` | Editors |
| `tmux/`, `zellij/` | Terminal multiplexers |
| `git/`, `pet/`, `atuin/`, `fastfetch/`, `bat/`, `glow/` | Tools |
| `lazygit/`, `lazydocker/`, `btop/`, `yazi/`, `mpv/`, `herdr/`, `distrobox/` | Apps |
| `hyprland/` | Desktop: Hyprland, Waybar, Mako, Walker, Wofi, and its `dots` commands |
| `themes/` | Palettes and theme files, used by `dots theme` |
| `packages/` | Saved package lists, written by `dots pkg save` |
| `docs/cheatsheets/` | Pages for `dots help` |
| `windows/` | GlazeWM, YASB, Windows Terminal, PowerShell and WSL configs |
| `ai/` | Agent configs, skills and prompts, mapped in `ai/README.md`; not linked |
| `self-hosted/`, `templates/` | Compose files and editor templates |

## Commands

`dots help dots` lists them; `dots --help` shows the arguments.

| Command | What it does |
| ------- | ------------ |
| `dots install` | Full setups: packages, config links, permissions, services |
| `dots stow` | Choose what is linked here |
| `dots pkg` | Install, remove, save and compare packages |
| `dots update` | Upgrade everything |
| `dots theme` | Switch colors, with a live preview |
| `dots doctor` | Report what is wrong |
| `dots edit`, `dots tui`, `dots help` | Open a config, a TUI or a page |
| `dots palette` | Command palette inside Zellij |
| `dots setup` | Set up a machine |
| `dots wsl` | WSL report, and copy configs to Windows |

## Rules

- The simple thing that works. A command runs; it does not check first.
- Clean, readable and commented. Everything in English.
- One script per command. Shared helpers only in `_ui` and `_managers`.
- Never commit tokens, history or real `.env` files.

## Current state

- Daily use: Arch on WSL, with zsh, Helix, fnm and Windows Terminal.
- In testing: vite-plus, next to fnm.
- Kept for later, not linked: `hyprland`, `tmux`, `vim`.
- Written but never run for real: the `hyprland` commands, `windows/`, and the setups
  in `dots install` that start services.
- Zellij: a bar with the mode and its keys, modes on Alt keys, and a command palette
  (`Alt /`).
- `ai/` is copied from the old repo and still needs a review.
- This repo has no remote yet. The old one is `oornnery/dotfiles`, branch `master`.

## Future

- Back to Arch on the desktop: `dots install hyprland`, then test its commands.
- Review `ai/` and link what stays.
- Try `tv` (television) in the Zellij palette, in place of fzf.
- Rebuild `self-hosted/`.
- One-time changes between machines, if more than one machine ever needs them.
