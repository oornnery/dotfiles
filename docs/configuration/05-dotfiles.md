# Dotfiles (Stow)

[GNU Stow](https://www.gnu.org/software/stow/) symlinks files from
`~/dotfiles/<package>/` into `~/`. Each top-level directory in this repo
is a stow package.

See also [docs/stow.md](../cheatsheets/stow.md) for the tool cheatsheet.

## Current packages

| Package         | Targets                                       |
| --------------- | --------------------------------------------- |
| Package         | Targets                                       |
| --------------- | --------------------------------------------- |
| `zsh/`          | `~/.zshrc`, `~/.zshenv`, `~/.zprofile`, `~/.zlogin`, `~/.zsh_functions` |
| `bash/`         | `~/.bashrc`                                   |
| `starship/`     | `~/.config/starship.toml`                     |
| `tmux/`         | `~/.tmux.conf`                                |
| `atuin/`        | `~/.config/atuin/config.toml`                 |
| `btop/`         | `~/.config/btop/btop.conf` + `themes/`        |
| `fastfetch/`    | `~/.config/fastfetch/config.jsonc`            |
| `bat/`          | `~/.config/bat/config`                        |
| `lazygit/`      | `~/.config/lazygit/config.yml`                |
| `lazydocker/`   | `~/.config/lazydocker/config.yml`             |
| `mpv/`          | `~/.config/mpv/mpv.conf`                      |
| `alacritty/`    | `~/.config/alacritty/alacritty.toml`          |
| `hyprland/`     | `~/.config/hypr/{hyprland,hypridle,hyprlock,bindings,monitors}.conf` |
| `nvim/`         | `~/.config/nvim/` (native, no plugins)        |
| `nvim.lazy/`    | `~/.config/nvim/` (native base + lazy.nvim plugins) |
| `nvim.mini/`    | `~/.config/nvim/` (mini.nvim distro)          |
| `git/`          | `~/.gitconfig`                                |
| `editor/`       | `~/.config/Code/`, `~/.config/Zed/`           |
| `fabric/`       | `~/.config/fabric-shell/`                     |
| `system/`       | system-level templates (consumed by scripts)  |
| `bin/`          | `~/.local/bin/{notice,web-app,hypr-scale}`    |
| `wsl/`          | `/etc/wsl.conf` (WSL only)                    |

## Workflow

The bootstrap module [`dev/stow.sh`](../../../scripts/arch/dev/stow.sh)
stows everything in one call (with sensible skips per platform).

Manually, from `~/dotfiles`:

```bash
stow -t ~ zsh                # link package "zsh" into $HOME
stow -t ~ -D zsh             # unlink (delete symlinks)
stow -t ~ -R zsh             # re-link (delete + relink)
stow -t ~ -n -v zsh          # dry-run with verbose output
```

## Adding a new package

1. Create the directory with the target path mirrored inside it:
   ```bash
   mkdir -p mycli/.config/mycli
   cp ~/.config/mycli/config.toml mycli/.config/mycli/
   ```
2. (Optional) add it to `packages=(…)` in [`dev/stow.sh`](../../../scripts/arch/dev/stow.sh)
   if you want `./arch.sh dev/stow` to pick it up automatically.
3. Stow it:
   ```bash
   stow -t ~ mycli
   ```

## Conflicts

Stow refuses to overlay an existing real file. If `~/.zshrc` exists from
a previous install, move or back it up:

```bash
mv ~/.zshrc{,.bak}
stow -t ~ zsh
```

`./arch.sh dev/stow` prints a warning per package on conflict; it
doesn't abort.
