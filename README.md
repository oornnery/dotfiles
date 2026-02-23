# Dotfiles

Personal terminal and editor setup for Debian, managed with GNU Stow.

## Table of contents

- [What is included](#what-is-included)
- [Quick install](#quick-install)
- [On-Prem stack](#on-prem-stack)
- [Stow usage (manual)](#stow-usage-manual)
- [Neovim](#neovim)
- [What I use (stack)](#what-i-use-stack)
- [Cheatsheet](#cheatsheet)
- [Notes](#notes)

## What is included

- `bash/` → `.bashrc`
- `zsh/` → `.zshrc` (Oh My Zsh + plugins)
- `nvim/` → Neovim configuration (LazyVim-based)
- `docs/` → Tool-specific cheatsheets and usage examples
- `scripts/debian.sh` → Debian bootstrap script
- `tmux/` → `.tmux.conf`
- `hyprland/` → Hyprland config
- `on-prem/` → local self-hosted stack (PostgreSQL, LiteLLM, Prometheus, Grafana)

## Quick install

### 1) Clone the repository

```bash
git clone https://github.com/oornnery/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

### 2) Run bootstrap

```bash
bash scripts/debian.sh
```

This script installs base packages (build tools, git, zsh, tmux, fzf, ripgrep, fd, eza, bat, node, go, rust, etc), installs Neovim, and sets up dotfiles with `stow`.

## On-Prem stack

The repository also includes a local observability + LLM stack under `on-prem/`:

- `database/` → PostgreSQL
- `litellm/` → LiteLLM proxy
- `monitoring/` → Prometheus + Grafana

Central guide:

- `on-prem/README.md`

Quick start:

```bash
cd on-prem/database && cp -n .env-example .env && docker compose up -d
cd ../litellm && cp -n .env-example .env && docker compose up -d
cd ../monitoring && cp -n .env-example .env && docker compose up -d
```

## Stow usage (manual)

If you want to apply modules manually:

```bash
stow -v -t ~ zsh
stow -v -t ~ bash
stow -v -t ~ nvim
stow -v -t ~ tmux
```

To remove symlinks for a module:

```bash
stow -D -v -t ~ zsh
```

## Neovim

- Config lives in `nvim/.config/nvim`
- Main entrypoint: `init.lua`
- Plugin manager: `lazy.nvim` (via LazyVim)
- Active `mini.nvim` modules: `basics`, `surround`, `comment`, `pairs`, `indentscope`, `animate`, `statusline`

## What I use (stack)

| Category             | Tool                                                                                                                                                           | Usage                                  |
| -------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------- |
| Shell                | [zsh](https://www.zsh.org/) + [Oh My Zsh](https://ohmyz.sh/)                                                                                                   | Main shell and terminal productivity   |
| Shell fallback       | [bash](https://www.gnu.org/software/bash/)                                                                                                                     | Compatibility and scripting            |
| Editor               | [Neovim](https://neovim.io/) + [LazyVim](https://www.lazyvim.org/)                                                                                             | Development and text editing           |
| Multiplexer          | [tmux](https://github.com/tmux/tmux)                                                                                                                           | Terminal sessions and splits           |
| Terminal UI          | [fastfetch](https://github.com/fastfetch-cli/fastfetch)                                                                                                        | System summary on terminal startup     |
| File navigation      | [eza](https://github.com/eza-community/eza) + tree                                                                                                             | Modern directory listing               |
| File viewing         | [bat](https://github.com/sharkdp/bat) (`batcat`)                                                                                                               | `cat` with syntax highlighting         |
| Search               | [fzf](https://github.com/junegunn/fzf) + [ripgrep](https://github.com/BurntSushi/ripgrep) + [fd](https://github.com/sharkdp/fd)                                | Fuzzy search, text search, file search |
| VCS                  | [git](https://git-scm.com/) + [gh](https://cli.github.com/)                                                                                                    | Version control and GitHub CLI         |
| OS packages          | [nala](https://gitlab.com/volian/nala) + [apt](https://wiki.debian.org/Apt)                                                                                    | Debian package install and updates     |
| Dotfiles             | [stow](https://www.gnu.org/software/stow/)                                                                                                                     | Symlink-based dotfile management       |
| JavaScript runtime   | [node](https://nodejs.org/) + [npm](https://www.npmjs.com/) + [pnpm](https://pnpm.io/) + [bun](https://bun.sh/)                                                | JS/TS projects                         |
| Python               | [python3](https://www.python.org/) + [pip](https://pip.pypa.io/) + [uv](https://docs.astral.sh/uv/)                                                            | Scripts and Python environments        |
| Python quality/tools | [ruff](https://docs.astral.sh/ruff/) + [ty](https://docs.astral.sh/ty/)                                                                                        | Lint/format and type checking          |
| Markdown tooling     | [rumdl](https://rumdl.dev/)                                                                                                                                    | Markdown linting and formatting        |
| Other languages      | [golang](https://go.dev/) + [rustc](https://www.rust-lang.org/)                                                                                                | Go and Rust development                |
| Build tools          | [make](https://www.gnu.org/software/make/) + [cmake](https://cmake.org/) + [ninja](https://ninja-build.org/) + [gcc](https://gcc.gnu.org/) (`build-essential`) | Compilation and tooling                |

## Cheatsheet

### rumdl workflow (Markdown)

- Format docs: `uvx rumdl fmt .`
- Lint docs: `uvx rumdl check .`
- CI-friendly check (no file changes): `uvx rumdl fmt --check . && uvx rumdl check .`
- Show what would change: `uvx rumdl fmt --diff .`

### Shell (zsh)

- `update` → `sudo nala update && sudo nala upgrade -y`
- `install <pkg>` → `sudo nala install <pkg>`
- `reload` → reload zsh (`exec zsh`)
- `edit` → open `.zshrc` in Neovim
- `ls` / `ll` / `tree` → `eza`-based versions
- `cat` / `catp` → `batcat`-based versions

### Neovim / LazyVim (useful shortcuts)

> Since you use the LazyVim base and have no extra custom keymaps yet, the shortcuts below are common defaults.

- `<Space>` = leader
- `<Space>ff` → find files
- `<Space>fg` → grep in project
- `<Space>e` → file explorer
- `<Space>w` → save
- `<Space>qq` → quit all

### mini.nvim (active modules)

- `mini.comment` → `gcc` (line), `gc` (motion/selection)
- `mini.surround` → `gsa` (add), `gsd` (delete), `gsr` (replace)
- `mini.basics` → utilities such as `gdelete`, `gwipe`, `gmove`

## Notes

- The `scripts/debian.sh` script asks for confirmation before applying each module with `stow`.
- If a destination file already exists (for example `~/.zshrc`), back it up first to avoid conflicts.
