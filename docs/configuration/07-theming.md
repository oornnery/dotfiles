# Theming

Themes live under [`themes/`](../../themes/) and are switched with one
command. They cover the visible day-to-day surfaces: alacritty, waybar,
wofi, mako, starship when present, tmux, Vim, Neovim and Zsh.

Hyprland borders are themed by editing `hyprland.conf` directly — kept
stable across themes to avoid churn.

## Switch themes

```bash
theme list             # show available + current
theme get              # show current
theme set tokyo-night  # activate
theme cycle            # rotate through the list
```

Hyprland bind: `Super + Ctrl + Alt + Y` cycles themes.

Daemons reload automatically:

- alacritty: `live_config_reload = true` picks up `theme.toml` on save
- mako: `makoctl reload`
- waybar: `pkill -SIGUSR2 waybar` (CSS reread)
- tmux: live server reload when a tmux session exists
- starship: next prompt
- Vim / Neovim / Zsh: next startup or manual config reload
- wofi: launches fresh per-invocation, no reload needed

## How it works

Each theme is a directory under [`themes/`](../../themes/) containing
drop-in files:

```
themes/<name>/
├── alacritty.toml    colors only (imported via general.import)
├── waybar.css        @define-color block (@import in style.css)
├── wofi.css          @define-color block (@import in style.css)
├── mako.config       colors only (include from mako config)
├── starship.toml     full starship config (optional drop-in)
├── tmux.conf         statusline/pane colors (sourced by tmux)
├── vim.vim           Vim highlights (sourced by .vimrc)
├── nvim.lua          Neovim palette table (read by lua/theme.lua)
└── zsh.zsh           Antigen theme + terminal-tool colors
```

The [`theme`](../applications/09-bin-scripts.md) script copies most of
them into the corresponding live paths. Neovim keeps `lua/theme.lua`
stow-managed; that file reads the active theme name from state, loads
`themes/<name>/nvim.lua` as a palette table, and applies the highlights:

| Source                         | Destination                              |
| ------------------------------ | ---------------------------------------- |
| `themes/<n>/alacritty.toml`    | `~/.config/alacritty/theme.toml`         |
| `themes/<n>/waybar.css`        | `~/.config/waybar/theme.css`             |
| `themes/<n>/wofi.css`          | `~/.config/wofi/theme.css`               |
| `themes/<n>/mako.config`       | `~/.config/mako/theme.config`            |
| `themes/<n>/starship.toml`     | `~/.config/starship.toml`                |
| `themes/<n>/tmux.conf`         | `~/.config/tmux/theme.conf`              |
| `themes/<n>/vim.vim`           | `~/.vim/theme.vim`                       |
| `themes/<n>/nvim.lua`          | read by `~/.config/nvim/lua/theme.lua`   |
| `themes/<n>/zsh.zsh`           | `~/.config/zsh/theme.zsh`                |

The active theme name is recorded in
`~/.local/share/dotfiles/active-theme`. `theme cycle` reads it to
determine the next theme in the list.

## Add a new theme

```bash
cp -r themes/catppuccin-mocha themes/gruvbox
$EDITOR themes/gruvbox/*               # change colors
theme set gruvbox
```

That's it — `theme list` discovers it automatically because it scans
`themes/*/`.

## Palette quick reference

| Slot       | mocha     | tokyo-night | latte     |
| ---------- | --------- | ----------- | --------- |
| bg         | `#1e1e2e` | `#1a1b26`   | `#eff1f5` |
| fg         | `#cdd6f4` | `#c0caf5`   | `#4c4f69` |
| accent     | `#f5c2e7` | `#7aa2f7`   | `#ea76cb` |
| red        | `#f38ba8` | `#f7768e`   | `#d20f39` |
| green      | `#a6e3a1` | `#9ece6a`   | `#40a02b` |
| yellow     | `#f9e2af` | `#e0af68`   | `#df8e1d` |
| blue       | `#89b4fa` | `#7aa2f7`   | `#1e66f5` |
| magenta    | `#f5c2e7` | `#bb9af7`   | `#ea76cb` |
| cyan       | `#94e2d5` | `#7dcfff`   | `#179299` |

## What isn't themed

- **Hyprland borders** — `col.active_border` in `hyprland.conf` stays
  pink (Catppuccin Mocha). Edit by hand if you want it to track theme.
- **GTK / Qt apps** — set those via `nwg-look` / `qt5ct` / `qt6ct`.
  Outside the scope of this theme switcher.
