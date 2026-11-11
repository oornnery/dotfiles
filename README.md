# dotfiles

Personal setup for Arch Linux on WSL, ready to go back to Arch on the desktop. Simple
scripts that just run, with every step safe to repeat. Start with `dots`.

## New machine

```bash
git clone https://github.com/oornnery/dotfiles ~/dotfiles && ~/dotfiles/bootstrap
```

It installs git and stow, links the `dots` command, then runs `dots apply`.

## How it works

Each folder in `home/` is a config package, linked into `$HOME` file by file with GNU
Stow. A setup links the config of what it installs: the env.d/ file of a language
(read by every shell), the theme of a TUI. `machines/<host>` says what each machine has: the tools set up there (`dots
install`) and the config packages linked there (`dots link`). `dots apply` makes a
machine match its file; `dots status` shows what does not match yet.

| Path | What it is |
| ---- | ---------- |
| `home/dots/` | The `dots` command: one script per subcommand in `.local/lib/dots/` |
| `home/shell/`, `home/zsh/`, `home/bash/` | Shell config; `shell/` is shared by zsh and bash |
| `home/<app>/` | The other config packages, mapped below |
| `machines/` | One file per machine: its tools, its links and its folders in `$HOME` |
| `recipes` | The tools `dots install` sets up: packages, config packages, group |
| `migrations/` | One-time changes per machine, run by `dots migrate` |
| `packages/` | Saved package lists, written by `dots pkg save` |
| `themes/` | Palettes and theme files, used by `dots theme` |
| `docs/cheatsheets/` | Pages for `dots help` |
| `system/` | Files installed outside `$HOME` by a setup, as root: the drive automount service |
| `windows/` | GlazeWM, YASB, Windows Terminal, PowerShell and WSL configs, the winget packages by group and the Windows settings |
| `ai/` | Agent configs, skills and prompts, mapped in `ai/README.md`; not linked |
| `self-hosted/`, `templates/` | Compose files and editor templates |
| `tests/` | `tests/run` checks every script and runs the tests; CI runs it too |
| `bootstrap` | The first run on a new machine |

## Commands

`dots --help` shows the arguments, `dots help dots` every action. This list comes from
the header of each command (`docs/generate`).

<!-- dots:commands -->
**machine**

| Command | What it does |
| ------- | ------------ |
| `dots apply` | Make this machine match its file in machines/: links, tools, packages |
| `dots doctor` | What is broken: links, tools, scripts, PATH, Node, language servers |
| `dots migrate` | Run the one-time changes this machine has not run yet |
| `dots status` | What is pending: commits, links, migrations, packages, Windows |

**config**

| Command | What it does |
| ------- | ------------ |
| `dots edit` | Pick a file in ~/dotfiles and open it in the editor |
| `dots link` | Keep configs in ~/dotfiles and link them into $HOME |
| `dots theme` | Switch the color theme: terminal, TUIs, prompt and editors |

**packages**

| Command | What it does |
| ------- | ------------ |
| `dots install` | Set up a tool: its packages, config links, permissions and services |
| `dots pkg` | Map installed packages to ~/dotfiles/packages and reinstall them |
| `dots try` | Try packages in a throwaway container, gone when you leave |
| `dots update` | Pending updates for system and dev tools; upgrade them all |

**use**

| Command | What it does |
| ------- | ------------ |
| `dots help` | Cheatsheets, plus your live aliases, functions and snippets |
| `dots palette` | Search TUIs, commands, keys, help, man pages and snippets, with a preview |
| `dots pane` | Run a command in a new Zellij pane, or right here outside Zellij |
| `dots preview` | Preview a file in the terminal: images, PDFs, folders, text |
| `dots tui` | Pick a TUI and open it |

**platform**

| Command | What it does |
| ------- | ------------ |
| `dots wsl` | WSL report (safe to paste) and wslc passthrough |

**desktop**

| Command | What it does |
| ------- | ------------ |
| `dots capture` | Screenshots, screen recording, OCR and color picker |
| `dots display` | Brightness, night light, zoom, wallpaper and screensaver |
| `dots hypr` | Hyprland: look, layout, monitors, gamemode, keybinds and reload |
| `dots notifications` | Notification history, do not disturb, reminders and info cards |
| `dots system` | Power menu and profiles, volume, GPU usage and hibernation |
| `dots webapp` | Web apps as windows (firefoxpwa) |
<!-- /dots:commands -->

## Rules

- The simple thing that works. A command runs; it does not check first.
- Clean, readable and commented. Everything in English.
- One script per command. Shared helpers only in `_ui` and `_managers`.
- Never commit tokens, history or real `.env` files.

## What is mapped

### Configs

`*` = linked on this machine (`machines/DESKTOP-T8DL9CB`). The rest is kept for later.

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
| `television` * | `~/.config/television/`: tv, on its own |
| `lazygit` *, `lazydocker` * | `~/.config/lazygit/`, `~/.config/lazydocker/` |
| `atuin` *, `pet` * | `~/.atuin/`, `~/.config/pet/` |
| `bat` *, `glow` *, `btop` *, `fastfetch` * | `~/.config/<name>/` |
| `herdr` *, `mpv` *, `distrobox` * | `~/.config/<name>/` |
| `hyprland` | Hyprland, Waybar, Mako, Walker, Wofi, Alacritty, and their `dots` commands |
| `tmux`, `vim` | `~/.tmux.conf`, `~/.vimrc` |
| `go`, `bun`, `deno`, `python`, `dotnet`, `postgres` | `~/.config/shell/env.d/<name>.sh`: paths and settings of that language; with `python`, `~/.config/uv/` |
| `sqlite`, `tealdeer`, `posting`, `presenterm`, `task`, `zk`, `eilmeldung` | `~/.config/<name>/`; `mise` also brings `env.d/node.sh` |

Not linked, copied by a command: `windows/` (`dots wsl windows`), `themes/` (`dots theme`).
Never in the repo: `~/.config/gh` (token), `~/.config/vite-plus`, shell history.

### Packages

Saved in `packages/` by `dots pkg save`; `dots pkg restore` brings them back.

| Manager | Packages |
| ------- | -------- |
| pacman | Base: `base base-devel sudo openssh man-db man-pages pacman-contrib stow git zsh` |
| | Shell: `atuin bat eza fd fzf ripgrep zoxide direnv gum jq yq xh tree unzip zip wget wl-clipboard` |
| | Editors and TUIs: `helix neovim vim zellij tmux yazi television lazygit lazydocker btop glow mpv ncdu fastfetch` |
| | Dev: `git-delta github-cli docker docker-buildx docker-compose distrobox mise uv rust ruff shellcheck shfmt hyperfine tokei` |
| | Language servers: `bash-language-server marksman taplo-cli yaml-language-server` |
| | Fonts: `ttf-firacode-nerd` |
| aur | `paru herdr-bin pet-bin pay-respects-bin pacsea-bin` |
| npm | `pnpm typescript typescript-language-server vscode-langservers-extracted` |
| uv | `basedpyright` |
| cargo | `epycell` |
| winget | 50 Windows apps in `windows/winget/packages.json` (`dots wsl windows export`) |

## Current state

- Daily use: Arch on WSL, with zsh, Helix, Zellij, Yazi, fzf and Windows Terminal.
- Node: mise, also for the versions of each project; vite-plus in testing, its Node after the one of mise.
- Kept for later, not linked: `hyprland`, `tmux`, `vim`.
- Written but never run for real: the `hyprland` commands, `dots wsl windows install`,
  and the setups in `dots install` that start services.
- `ai/` is copied from the old repo and still needs a review.
- Remote: `oornnery/dotfiles`; work goes to `dev`, then a PR to `master`.

Ideas and what comes next are in [TODO.md](TODO.md).
