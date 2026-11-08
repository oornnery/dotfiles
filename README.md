# dotfiles

Personal setup for Arch Linux on WSL, ready to go back to Arch on the desktop. Simple
scripts that just run, with every step safe to repeat. Start with `dots`.

## New machine

```bash
git clone https://github.com/oornnery/dotfiles ~/dotfiles && ~/dotfiles/bootstrap
```

It installs git and stow, links the `dots` command, then runs `dots apply`.

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
| `windows/` | GlazeWM, YASB, Windows Terminal, PowerShell and WSL configs, and the winget packages |
| `ai/` | Agent configs, skills and prompts, mapped in `ai/README.md`; not linked |
| `self-hosted/`, `templates/` | Compose files and editor templates |

## Commands

`dots help dots` lists them; `dots --help` shows the arguments.

| Command | What it does |
| ------- | ------------ |
| `dots install` | Full setups: packages, config links, permissions, services |
| `dots link` | Choose what is linked here |
| `dots pkg` | Install, remove, save and compare packages |
| `dots update` | Upgrade everything |
| `dots theme` | Switch colors, with a live preview |
| `dots status` | What is pending: commits, links, new configs, packages, Windows |
| `dots doctor` | Report what is wrong |
| `dots edit`, `dots tui`, `dots help` | Open a config, a TUI or a page |
| `dots palette` | Search help, TUIs and commands with tv |
| `dots apply` | Make this machine match the repo |
| `dots wsl` | WSL report, and copy configs to Windows |

## Rules

- The simple thing that works. A command runs; it does not check first.
- Clean, readable and commented. Everything in English.
- One script per command. Shared helpers only in `_ui` and `_managers`.
- Never commit tokens, history or real `.env` files.

## What is mapped

### Configs

`*` = linked on this machine (`~/.config/dots/packages`). The rest is kept for later.

| Package | Links |
| ------- | ----- |
| `dots` * | `~/.local/bin/dots`, `~/.local/lib/dots/` |
| `shell` * | `~/.config/shell/`: aliases, functions, tools, prompt, keys; shared by zsh and bash |
| `zsh` * | `~/.zshrc`, `~/.zshenv` |
| `bash` * | `~/.bashrc`, `~/.bash_profile`, `~/.inputrc` |
| `git` * | `~/.gitconfig` |
| `helix` * | `~/.config/helix/` |
| `nvim` * | `~/.config/nvim/` |
| `zellij` * | `~/.config/zellij/`: config with zjstatus, layout `dev` |
| `yazi` * | `~/.config/yazi/` |
| `television` * | `~/.config/television/`: the `dots palette` channels |
| `lazygit` *, `lazydocker` * | `~/.config/lazygit/`, `~/.config/lazydocker/` |
| `atuin` *, `pet` * | `~/.atuin/`, `~/.config/pet/` |
| `bat` *, `glow` *, `btop` *, `fastfetch` * | `~/.config/<name>/` |
| `herdr` *, `mpv` *, `distrobox` * | `~/.config/<name>/` |
| `hyprland` | Hyprland, Waybar, Mako, Walker, Wofi, Alacritty, and their `dots` commands |
| `tmux`, `vim` | `~/.tmux.conf`, `~/.vimrc` |

Not linked, copied by a command: `windows/` (`dots wsl windows`), `themes/` (`dots theme`).
Never in the repo: `~/.config/gh` (token), `~/.config/vite-plus`, shell history.

### Packages

Saved in `packages/` by `dots pkg save`; `dots pkg restore` brings them back.

| Manager | Packages |
| ------- | -------- |
| pacman | Base: `base base-devel sudo openssh man-db man-pages pacman-contrib stow git zsh` |
| | Shell: `atuin bat eza fd fzf ripgrep zoxide direnv gum jq yq xh tree unzip zip wget wl-clipboard` |
| | Editors and TUIs: `helix neovim vim zellij tmux yazi television lazygit lazydocker btop glow mpv ncdu fastfetch` |
| | Dev: `git-delta github-cli docker docker-buildx docker-compose distrobox fnm uv rust ruff shellcheck shfmt hyperfine tokei` |
| | Language servers: `bash-language-server marksman taplo-cli yaml-language-server` |
| | Fonts: `ttf-firacode-nerd` |
| aur | `paru herdr-bin pet-bin pay-respects-bin pacsea-bin` |
| npm | `pnpm typescript typescript-language-server vscode-langservers-extracted` |
| uv | `basedpyright` |
| cargo | `epycell` |
| winget | 50 Windows apps in `windows/winget/packages.json` (`dots wsl windows export`) |

## Current state

- Daily use: Arch on WSL, with zsh, Helix, Zellij, Yazi, tv and Windows Terminal.
- Node: fnm, with vite-plus in testing. Both set up a Node, so only one stays (TODO.md).
- Kept for later, not linked: `hyprland`, `tmux`, `vim`.
- Written but never run for real: the `hyprland` commands, `dots wsl windows install`,
  and the setups in `dots install` that start services.
- `ai/` is copied from the old repo and still needs a review.
- Remote: `oornnery/dotfiles`; work goes to `dev`, then a PR to `master`.

Ideas and what comes next are in [TODO.md](TODO.md).
