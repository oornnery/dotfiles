# Windows Desktop (komorebi + yasb + whkd) Cheatsheet

Mirrors the Hyprland + AGS setup from this dotfiles repo. Modifier convention:

> `alt` ≡ `M` (Super)
> `alt+shift` ≡ `MS`
> `alt+ctrl` ≡ `MC`
> `ctrl+alt+shift` ≡ `MCA`
>
> Windows reserves many `Win+*` chords; using `alt` as the primary modifier
> matches the i3 / sway convention and avoids OS conflicts.

## Apps

| Bind            | Action                                                  |
| --------------- | ------------------------------------------------------- |
| `Alt+Return`    | Windows Terminal                                        |
| `Alt+E`         | File Explorer                                           |
| `Alt+R`         | Flow Launcher (walker analog)                           |
| `Alt+B`         | Browser (firefox)                                       |
| `Alt+L`         | Lock workstation                                        |
| `Alt+Shift+P`   | Power menu (lock / sleep / signout / restart / shutdown)|
| `Alt+M`         | Stop komorebi                                           |
| `` Alt+` ``     | Scratchpad (Windows Terminal float toggle)              |

## Window management

| Bind                | Action                                  |
| ------------------- | --------------------------------------- |
| `Alt+Shift+Q`       | Close focused window                    |
| `Alt+T`             | Toggle floating                         |
| `Alt+P`             | Toggle monocle (≈ pseudo)               |
| `Alt+J`             | Toggle split orientation                |
| `Alt+F`             | Toggle maximize (≈ fullscreen)          |
| `Alt+←/→/↑/↓`       | Focus direction                         |
| `Alt+H/L/K/J`       | Focus direction (vi-style)              |
| `Alt+Shift+←/→/↑/↓` | Move window in direction                |
| `Alt+Tab`           | Cycle to next monitor                   |
| `Alt+Shift+Tab`     | Cycle to previous monitor               |

## Workspaces (komorebi)

| Bind                | Action                            |
| ------------------- | --------------------------------- |
| `Alt+1..9,0`        | Focus workspace 1..10             |
| `Alt+Shift+1..9,0`  | Move window to workspace 1..10    |
| `Alt+Scroll up`     | Previous workspace                |
| `Alt+Scroll down`   | Next workspace                    |
| `Alt+Ctrl+Alt+L`    | Cycle layout (BSP/Cols/Rows/…)    |
| `Alt+S`             | Toggle workspace layer            |
| `Alt+Shift+S`       | Send to "scratch" named workspace |

## Screenshots

| Bind                | Action                            |
| ------------------- | --------------------------------- |
| `Win+Shift+S`       | Region (built-in)                 |
| `Ctrl+Alt+3`        | Region via ShareX                 |
| `Ctrl+Alt+4`        | Full screen via ShareX            |
| `Alt+Shift+F`       | Region → clipboard via ShareX     |

## Pickers / TUIs

| Bind            | Action                                       |
| --------------- | -------------------------------------------- |
| `Alt+V`         | Clipboard history (Flow Launcher plugin)     |
| `Alt+.`         | Emoji panel (built-in `Win+.` for now)       |
| `Alt+Shift+G`   | lazygit in floating Windows Terminal         |
| `Alt+Shift+D`   | lazydocker                                   |
| `Alt+Shift+T`   | btop                                         |
| `Alt+I`         | LLM picker (Claude Code in terminal)         |
| `Alt+Shift+H`   | Cheatsheet (this file via fzf + glow + less) |
| `Alt+N`         | Obsidian today's note                        |

## Bar (yasb)

Same module set + colors as AGS:

```
LEFT:   home  workspaces  layout  media
CENTER: clock
RIGHT:  github  updates  cpu  memory  gpu  cpu_temp  wifi  bluetooth
        volume  brightness  battery  language  power_menu
```

- **Click clock** → calendar popup
- **Click volume / brightness** → slider tooltip + scroll-to-adjust
- **Click battery** → percentage + time-remaining tooltip
- **Click power_menu** → blur-background full-screen menu
- **Right-click any pill** → toggles between `label` (compact) and `label_alt` (verbose)

## Installation

```powershell
# Run once (admin needed for the symlinks at the end)
pwsh.exe -ExecutionPolicy Bypass -File $Env:USERPROFILE\dotfiles\windows\scripts\install-stack.ps1

# Then start the stack
komorebic start --whkd --bar
```

To autostart on login, drop a shortcut into `shell:startup` pointing at
`komorebic.exe start --whkd --bar`.

## Files in this repo

```
windows/
├── komorebi/
│   ├── komorebi.json          # WM config (borders, padding, monitors, rules)
│   ├── applications.yaml      # Per-app float/ignore rules
│   ├── power-menu.ps1         # Alt+Shift+P
│   ├── scratchpad.ps1         # Alt+`
│   └── cheatsheet.ps1         # Alt+Shift+H (this picker)
├── whkd/
│   └── whkdrc                 # All keybindings (mirrors Hyprland bindings.lua)
├── yasb/
│   ├── config.yaml            # Bar widgets + layout
│   └── styles.css             # Theme + visual
├── scripts/
│   ├── install-stack.ps1      # One-shot setup
│   └── win.ps1                # General PS helpers (pre-existing)
└── docs/
    └── cheatsheet.md          # this file
```

## Tips

| Tip                                                  | Why                                             |
| ---------------------------------------------------- | ----------------------------------------------- |
| Edit `whkdrc` then `Stop-Process whkd; whkd`         | Hot-reload after binding changes                |
| `komorebic reload-configuration`                     | Reload komorebi.json without restarting WM      |
| yasb has `watch_stylesheet: true`                    | Edit styles.css → bar updates live              |
| Use `komorebic query state`                          | Inspect current workspace/monitor state         |
| `komorebic log` shows recent events                  | Debug rule mismatches                           |
| `komorebic application-specific-configuration-schema`| Generate strongly-typed applications.yaml       |
