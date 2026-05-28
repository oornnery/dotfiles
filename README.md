# Dotfiles

Personal terminal, editor, and Windows/WSL setup, managed primarily with GNU Stow on Linux.

## Table of contents

- [Manual](docs/README.md) — full reference, omarchy-style topics
- [What is included](#what-is-included)
- [Quick install](#quick-install)
- [Windows and WSL](#windows-and-wsl)
- [Stow usage (manual)](#stow-usage-manual)
- [Neovim](#neovim)
- [What I use (stack)](#what-i-use-stack)
- [Cheatsheet](#cheatsheet)
- [Notes](#notes)

## What is included

- `bash/` → `.bashrc`
- `zsh/` → `.zshrc` (Oh My Zsh + plugins)
- `nvim/` → native Neovim configuration
- `nvim.lazy/` → native Neovim base plus lazy.nvim plugin extras
- `nvim.mini/` → mini.nvim-based Neovim distro
- `editor/` → VS Code and Zed settings for the Windows setup
- `docs/` → Full reference (basics, applications, configuration, cheatsheets)
- `scripts/debian.sh` → Debian bootstrap script
- `scripts/zsh.sh` → Oh My Zsh and plugin setup
- `scripts/arch.sh` → Arch Linux bootstrap (native + WSL + VMs, hardware-aware: AMD/Intel/NVIDIA GPU, Vaio/Dell DMI quirks, VM guest tools)
- `tmux/` → `.tmux.conf`
- `wsl/` → WSL configuration (`.wslconfig`, `etc/wsl.conf` template for `arch.sh`)
- `system/` → System config templates consumed by `scripts/arch.sh` (zram, NetworkManager iwd backend)
- `git/` → `.gitconfig` (stowed; `arch.sh` detects and skips re-prompting)
- `hyprland/` → Hyprland config

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

### 3) Other setup scripts

- `bash scripts/zsh.sh` to install Oh My Zsh and the shell plugins used in this setup.
- `sudo bash scripts/arch.sh` to bootstrap an Arch Linux environment. Auto-detects WSL, VM (qemu/kvm/vbox/vmware/hyper-v), bare-metal laptop, CPU vendor (Intel/AMD), GPU vendor (AMD/Intel/NVIDIA), and DMI vendor (Vaio/Dell). Flags: `--unattended` (CI), `--dry-run` (show plan only). Env overrides: `USER_NAME`, `TIMEZONE`, `MIRROR_COUNTRY`, `GIT_NAME`, `GIT_EMAIL`, `LOG_FILE`. Run AFTER archinstall.

## Windows and WSL

The repository also includes Windows-oriented setup files:

- `editor/README.md` documents the shared VS Code and Zed setup, required tools, and frontend defaults.
- `editor/Code/.vscode/` contains workspace recommendations and settings for VS Code.
- `editor/Zed/.zed/settings.json` contains the Zed profile used in this setup.
- `wsl/.wslconfig` contains the local WSL2 resource profile.

Then review the editor docs:

```text
editor/README.md
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

- `nvim/` is the native base: no plugin manager, built-in features only.
- `nvim.lazy/` loads `nvim/` first, then adds lazy.nvim plugins.
- `nvim.mini/` is a separate mini.nvim distro.
- All three target `~/.config/nvim`, so stow only one at a time.

## What I use (stack)

| Category             | Tool                                                                                                                                                           | Usage                                  |
| -------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------- |
| Shell                | [zsh](https://www.zsh.org/) + [Oh My Zsh](https://ohmyz.sh/)                                                                                                   | Main shell and terminal productivity   |
| Shell fallback       | [bash](https://www.gnu.org/software/bash/)                                                                                                                     | Compatibility and scripting            |
| Editor               | [Neovim](https://neovim.io/) with native/lazy.nvim/mini.nvim dotfile variants                                                                                   | Development and text editing           |
| GUI editors          | [VS Code](https://code.visualstudio.com/) + [Zed](https://zed.dev/)                                                                                            | Windows editor setup                   |
| Multiplexer          | [tmux](https://github.com/tmux/tmux)                                                                                                                           | Terminal sessions and splits           |
| Terminal UI          | [fastfetch](https://github.com/fastfetch-cli/fastfetch)                                                                                                        | System summary on terminal startup     |
| File navigation      | [eza](https://github.com/eza-community/eza) + tree                                                                                                             | Modern directory listing               |
| File viewing         | [bat](https://github.com/sharkdp/bat) (`batcat`)                                                                                                               | `cat` with syntax highlighting         |
| Search               | [fzf](https://github.com/junegunn/fzf) + [ripgrep](https://github.com/BurntSushi/ripgrep) + [fd](https://github.com/sharkdp/fd)                                | Fuzzy search, text search, file search |
| VCS                  | [git](https://git-scm.com/) + [gh](https://cli.github.com/)                                                                                                    | Version control and GitHub CLI         |
| OS packages          | [nala](https://gitlab.com/volian/nala) + [apt](https://wiki.debian.org/Apt)                                                                                    | Debian package install and updates     |
| Dotfiles             | [stow](https://www.gnu.org/software/stow/)                                                                                                                     | Symlink-based dotfile management       |
| Windows packages     | [winget](https://learn.microsoft.com/windows/package-manager/winget/)                                                                                          | Windows bootstrap and app installs     |
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

### Neovim (useful shortcuts)

- `<Space>` = leader
- `<Space>ff` → find files
- `<Space>sg` → grep in project with native quickfix
- `<Space>e` → file explorer
- `<Space>w` → save
- `<Space>q` → quit window
- `<Space>?` → cheatsheet

### mini.nvim (active modules)

- `mini.comment` → `gcc` (line), `gc` (motion/selection)
- `mini.surround` → `gsa` (add), `gsd` (delete), `gsr` (replace)
- `mini.basics` → utilities such as `gdelete`, `gwipe`, `gmove`

## Notes

- The `scripts/debian.sh` script asks for confirmation before applying each module with `stow`.
- The Windows side is intentionally separate from the Linux `stow` flow and is documented under `editor/`.
- `wsl/.wslconfig` is machine-level configuration and should be adapted to the RAM/CPU available on the host.
- If a destination file already exists (for example `~/.zshrc`), back it up first to avoid conflicts.
