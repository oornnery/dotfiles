# Navigation

Hyprland keybindings, grouped by intent. Full source:
[`hyprland/.config/hypr/bindings.conf`](../../../hyprland/.config/hypr/bindings.conf).

> `$mainMod = SUPER`. Single-key launches use `Super + KEY`. Window
> actions tend to use `Super + Shift + KEY`. On-demand info uses
> `Super + Ctrl + Alt + KEY`. TUI launches use `Super + Shift + <letter>`.

## Apps

| Bind                | Action               |
| ------------------- | -------------------- |
| `Super + Q`         | terminal (alacritty) |
| `Super + E`         | file manager         |
| `Super + R`         | wofi app launcher    |
| `Super + B`         | browser (firefox)    |
| `Super + L`         | lock screen          |
| `Super + Shift + E` | logout menu          |

## Window management

| Bind                       | Action                       |
| -------------------------- | ---------------------------- |
| `Super + C`                | close window                 |
| `Super + V`                | toggle float                 |
| `Super + F`                | fullscreen                   |
| `Super + P`                | pseudo (dwindle)             |
| `Super + J`                | toggle split (dwindle)       |
| `Super + ←/→/↑/↓`          | move focus                   |
| `Super + Shift + ←/→/↑/↓`  | move window                  |
| `Super + LMB drag`         | move window                  |
| `Super + RMB drag`         | resize window                |

## Workspaces

| Bind                 | Action                       |
| -------------------- | ---------------------------- |
| `Super + 1…0`        | switch to workspace          |
| `Super + Shift + 1…0`| move window to workspace     |
| `Super + S`          | toggle scratchpad            |
| `Super + Shift + S`  | send window to scratchpad    |
| `Super + scroll`     | cycle workspaces             |

## Screenshots

| Bind                  | Action                                |
| --------------------- | ------------------------------------- |
| `Print`               | region → satty (annotate & save)      |
| `Super + Print`       | full screen → clipboard               |
| `Super + Shift + F`   | region → clipboard (no annotate)      |

## Clipboard / picker

| Bind                | Action                                          |
| ------------------- | ----------------------------------------------- |
| `Super + V`         | clipboard history (cliphist via wofi)           |
| `Super + Shift + C` | color picker (hyprpicker)                       |

## TUIs (floating alacritty)

| Bind                  | Tool                |
| --------------------- | ------------------- |
| `Super + Shift + G`   | lazygit             |
| `Super + Shift + D`   | lazydocker          |
| `Super + Shift + T`   | btop                |
| `Super + Shift + B`   | bluetui             |
| `Super + Shift + W`   | impala (Wi-Fi/iwd)  |
| `Super + Shift + Alt + M` | cliamp (music)  |

## Web apps (firefoxpwa)

| Bind            | App        |
| --------------- | ---------- |
| `Super + Ctrl + G` | ChatGPT |
| `Super + Ctrl + W` | WhatsApp |
| `Super + Ctrl + Y` | YouTube |
| `Super + Ctrl + X` | X       |
| `Super + Ctrl + Z` | Zoom    |

## Notices

See [Notices](06-notices.md).

| Bind                    | Topic     |
| ----------------------- | --------- |
| `Super + Ctrl + Alt + T`| date      |
| `Super + Ctrl + Alt + W`| weather   |
| `Super + Ctrl + Alt + B`| battery   |
| `Super + Ctrl + Alt + N`| network   |
| `Super + Ctrl + Alt + S`| system    |

## Display

| Bind                | Action                                            |
| ------------------- | ------------------------------------------------- |
| `Super + /`         | monitor scale +0.1 (`hypr-scale`)                 |
| `Super + Alt + /`   | monitor scale -0.1                                |
| `Super + =`         | magnify in (zoom +0.5x)                           |
| `Super + -`         | magnify out                                       |
| `Super + Shift + M` | magnify toggle (1.0 ↔ 1.5x)                       |

## System toggles

| Bind                       | Action                                       |
| -------------------------- | -------------------------------------------- |
| `Super + Ctrl + Alt + Y`   | `theme cycle` — alacritty/waybar/wofi/mako   |
| `Super + Ctrl + Alt + P`   | `power-profile cycle` — power-saver/balanced/performance |
| `Super + Ctrl + Alt + D`   | `dnd` — toggle mako Do-Not-Disturb           |
| `Super + Ctrl + Alt + M`   | `night-mode` — toggle hyprsunset             |
| `Super + Ctrl + Alt + R`   | `record` — toggle screen recording           |
| `Super + Shift + O`        | `ocr` — region → tesseract → clipboard       |
| `Super + Shift + Tab`      | `window-finder` — wofi list of windows       |
| `Super + grave`            | `scratch` — quake-style scratchpad           |

## Multimedia

Handled by custom `bin/brightness` and `bin/volume` scripts with mako
progress notifications (no swayosd-server).

| Key                              | Action                  |
| -------------------------------- | ----------------------- |
| `XF86AudioRaiseVolume`           | `volume raise`          |
| `XF86AudioLowerVolume`           | `volume lower`          |
| `XF86AudioMute`                  | `volume mute-toggle`    |
| `XF86AudioMicMute`               | `volume mic-mute-toggle`|
| `XF86MonBrightnessUp/Down`       | `brightness raise/lower`|
| `XF86AudioNext/Prev/Play/Pause`  | playerctl               |

## Terminal window manager (herdr)

One vocabulary for moving, from the desktop down to a split inside the editor:

| Layer | Move | Create / close | Jump |
| ----- | ---- | -------------- | ---- |
| Hyprland (GUI) | `Super+H/J/K/L` | `Super+Enter`, `Super+Q` | `Super+1..9` workspace |
| herdr workspace | — | `prefix+shift+n` / `prefix+shift+d` | `prefix+w`, `prefix+t`, `prefix+l` back |
| herdr tab | `prefix+h/j/k/l` inside the tab bar | `prefix+c` / `prefix+shift+x` | `prefix+1..9` |
| herdr pane | `prefix+h/j/k/l` or `Alt+h/j/k/l` | `prefix+v` / `prefix+-`, `prefix+x` | `prefix+g` |
| Neovim split | `Ctrl+h/j/k/l` (crosses the edge into herdr) | `<Space>vs` / `<Space>q` | `<Space>1..9` |
| lazygit / lazydocker | `hjkl`, `[` / `]` panels | `?` shows every binding | `q` |
| zsh | `Ctrl+X Ctrl+R` snippet, `Ctrl+R` history | — | `Ctrl+T` file path |

`Alt+h/j/k/l` is the pane chord because `Ctrl+h/j/k/l` belongs to readline and to
the TUIs running inside the panes. Full key tables:
[herdr](../cheatsheets/herdr.md), [neovim](../cheatsheets/neovim.md),
[TUIs](../applications/05-tuis.md), [pet](../cheatsheets/pet.md).
