# Terminal

[Alacritty](https://alacritty.org) is the primary terminal, with
[ghostty](https://ghostty.org) installed alongside as a fallback. Tmux
handles sessions/splits inside whichever terminal you launched.

## Hyprland integration

```bash
# hyprland/.config/hypr/hyprland.conf
$terminal = alacritty

# hyprland/.config/hypr/bindings.conf
bind = $mainMod, Q, exec, $terminal
```

`Super + Q` opens a new terminal. To attach to an existing tmux session
automatically, use:

```bash
alacritty -e tmux new-session -A -s main
```

## Alacritty config

[`alacritty/.config/alacritty/alacritty.toml`](../../../alacritty/.config/alacritty/alacritty.toml)

Highlights:

- `opacity = 0.95`, `padding = 8`, `decorations = None` (Hyprland borders win)
- JetBrains Mono Nerd Font, size 11
- Catppuccin Mocha palette — matches starship, tmux status, and Hyprland
  active border (`color212` pink)
- `save_to_clipboard = true` — selection auto-copies
- `live_config_reload = true` — edit and save, no restart

Open a second instance: `Ctrl + Shift + T` (rebound to `SpawnNewInstance`).
Fullscreen: `F11`.

## Tmux config

[`tmux/.tmux.conf`](../../../tmux/.tmux.conf)

Prefix swapped from `C-b` → `C-a` (easier reach). After stowing, reload with
`tmux source ~/.tmux.conf` inside a running session, or just open a new one.

Key bindings (after `C-a`):

| Bind         | Action                                       |
| ------------ | -------------------------------------------- |
| `\|`          | split right (vertical)                       |
| `-`          | split below (horizontal)                     |
| `h`/`j`/`k`/`l` | navigate panes (vim-style)                |
| `H`/`J`/`K`/`L` | resize panes (capital, repeatable)        |
| `c`          | new window in `$PWD`                         |
| `r`          | reload config                                |
| `v` (copy mode) | begin selection                          |
| `y` (copy mode) | yank selection to clipboard (wl-copy)    |

No prefix:

| Bind        | Action                  |
| ----------- | ----------------------- |
| `Alt + 1…5` | jump to window N        |
| Mouse       | scroll, click pane/tab  |

Status bar: pink session name on the left, weekday + date + clock on the
right. Borders + message style match the rest of the palette.

## Why two terminals?

Alacritty is fast, predictable, and minimal. Ghostty is great too, with
better ligature handling and built-in image preview, but it pulls more
deps. Keep both — `$terminal` controls which one Hyprland's `Super + Q`
launches.
