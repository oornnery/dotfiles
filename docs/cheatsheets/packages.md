# Packages and dotfiles

What is on this machine and why, by group. Open it with `dots help packages`.
The real lists are in `packages/*.txt` (`dots pkg save`); after installing or
removing something, update this file too.

Source, when it is not pacman: `aur`, `npm`, `uv`, `cargo`.

## TUIs

| Run | Package | For |
| --- | --- | --- |
| `helix` / `hx` | `helix` | Editor |
| `nvim` | `neovim` | Full editor: LSP, debug and tests for any language |
| `tmux` | `tmux` | Terminal multiplexer; may be removed, its config stays |
| `lazygit` / `lg` | `lazygit` | Git |
| `lazydocker` / `ld` | `lazydocker` | Docker containers, logs, stats |
| `btop` | `btop` | CPU, memory, processes |
| `ncdu` | `ncdu` | Disk usage |
| `pacsea` | `pacsea-bin` (aur) | Search and install pacman and AUR packages |
| `glow` | `glow` | Browse and read Markdown |
| `herdr` | `herdr-bin` (aur) | Workspaces for AI coding agents |
| `zellij` | `zellij` | Panes and tabs |
| `yazi` | `yazi` | File manager |
| `tv` | `television` | Fuzzy finder with channels |
| `epycell` | `epycell` (cargo) | Jupyter notebooks in the terminal |

## Shell

| Package | For |
| --- | --- |
| `zsh` | Main shell |
| `atuin` | History search |
| `fzf` | Fuzzy finder: Ctrl-T files, Alt-C folders, Tab with fzf-tab |
| `zoxide` | `z` and `zi`: jump to folders |
| `direnv` | Per-folder `.envrc` |
| `pet-bin` (aur) | Snippets: Ctrl-X Ctrl-R |
| `pay-respects-bin` (aur) | `fuck`: fix the last failed command |
| `fastfetch` | System info when a terminal opens |
| `gum` | Prompts and menus in the `dots` scripts |

## Files and text

| Package | Replaces or does |
| --- | --- |
| `eza` | `ls` (`ll`, `la`, `lt`) |
| `bat` | `cat` (`b`), man pages, fzf previews |
| `fd` | `find` |
| `ripgrep` | `grep` (`rg`) |
| `tree` | Folder tree |
| `jq` | JSON |
| `yq` | YAML, XML, TOML |
| `zip`, `unzip` | Archives |
| `wl-clipboard` | Clipboard for Helix on WSLg |

## Media

| Package | For |
| --- | --- |
| `mpv` | Video and audio player |
| `ttf-firacode-nerd` | Font for Linux GUI apps on WSLg; the terminal uses Windows fonts |

## Git and network

| Package | For |
| --- | --- |
| `git` | Version control |
| `git-delta` | Colored diffs, used as the git pager when installed |
| `github-cli` | `gh`: GitHub |
| `openssh` | `ssh` |
| `wget` | Downloads |
| `xh` | HTTP requests |

## Containers

| Package | For |
| --- | --- |
| `docker`, `docker-buildx`, `docker-compose` | Docker (`d`, `dc`, `dcu`, `dcd`, `dcl`, `dps`) |
| `distrobox` | Other distros inside containers |

## Languages and runtimes

| Package | For |
| --- | --- |
| `uv` | Python projects and tools |
| `fnm` | Node versions; the main one, active in interactive shells |
| `pnpm` (npm) | Node packages |
| `typescript` (npm) | TypeScript compiler |
| `rust` | Rust and `cargo` |

`vite-plus` (`vp`) is being tested. It comes from its own installer, outside
these lists, and has its own Node, so `npm` outside an interactive shell is a
different one with its own global packages.

## Helix language servers and formatters

| Package | Language |
| --- | --- |
| `ruff` | Python: lint and format |
| `basedpyright` (uv) | Python: types |
| `bash-language-server`, `shellcheck`, `shfmt` | Shell |
| `taplo-cli` | TOML |
| `marksman` | Markdown |
| `yaml-language-server` | YAML |
| `typescript-language-server` (npm) | TypeScript, JavaScript |
| `vscode-langservers-extracted` (npm) | JSON, HTML, CSS |

Check them with `helix --health`.

## Dev utilities

| Package | For |
| --- | --- |
| `hyperfine` | Benchmark commands |
| `tokei` | Count lines of code |
| `shellcheck` | Lint shell scripts (also used by Helix) |

## System and packages

| Package | For |
| --- | --- |
| `base`, `base-devel` | Arch base and build tools |
| `sudo` | Root commands |
| `man-db`, `man-pages` | `man` |
| `paru` (aur) | AUR helper |
| `pacman-contrib` | `checkupdates`, used by `dots update` |
| `stow` | Links the dotfiles, used by `dots link` |

## To review

Installed, but not part of the setup described above.

| Package | Why it is here |
| --- | --- |
| `paru-debug` (aur) | Debug symbols, created when building paru |

## Dotfiles

Stow packages, linked by `dots link sync` from `~/.config/dots/packages`.

| Package | Holds |
| --- | --- |
| `dots` | The `dots` command and its subcommands |
| `shell` | Shared by zsh and bash: env, aliases, functions, tools, conf.d |
| `zsh` | `.zshrc`, `.zshenv` |
| `bash` | `.bashrc`, `.bash_profile`, `.inputrc` |
| `git` | `.gitconfig` |
| `helix` | Editor and language config |
| `pet` | Snippets and config |
| `distrobox` | `distrobox.conf` |
| `atuin` | History search config; its data stays out of the repo |
| `fastfetch` | System info layout |
| `herdr` | Config and plugin keys; plugins come from a pet snippet |
| `nvim` | Full Neovim config; plugins and servers install on first run |
| `lazygit`, `lazydocker`, `btop`, `yazi` | TUI configs |
| `bat`, `glow`, `mpv` | Tool configs |

Kept but not linked. Turn one on with `dots link <name>`.

| Package | Holds |
| --- | --- |
| `vim` | Small `.vimrc` without plugins, same keys as Helix |
| `tmux` | Small `.tmux.conf`, same theme as Helix |
| `zellij` | Theme, help, the keys for `dots palette` and the `dev` layout |
| `television` | The modes of `dots palette`, as tv channels |
| `hyprland` | Hyprland, Alacritty, Waybar, Mako, Walker, Wofi and the commands `capture`, `display`, `hypr`, `notifications`, `system`, `webapp`; not used on WSL |

In the repo, but not stow packages:

| Folder | Holds |
| --- | --- |
| `themes/` | Palettes and theme files, used by `dots theme` |
| `ai/` | Claude, Codex, OpenCode and Pi configs, skills and agents; see `ai/README.md` |
| `windows/` | GlazeWM, YASB, Windows Terminal, PowerShell and WSL configs |
| `self-hosted/` | Docker Compose structure; real `.env` files stay out of git |
| `templates/` | Editor templates for new projects |
| `packages/`, `docs/` | Package lists and these cheatsheets |

## Colors

`dots theme` sets the terminal palette, and everything here using ANSI colors
follows: prompt, fzf, bat, eza, lazygit, lazydocker, btop, yazi, fastfetch, glow.
Helix switches to its matching built-in theme.
