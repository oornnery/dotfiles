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

| Bind                | Action               |
| ------------------- | -------------------- |
| `Super + /`         | scale +0.1           |
| `Super + Alt + /`   | scale -0.1           |

## Multimedia

Handled by `swayosd-client` for visual feedback:

| Key              | Action                  |
| ---------------- | ----------------------- |
| `XF86AudioRaise` | volume +                |
| `XF86AudioLower` | volume -                |
| `XF86AudioMute`  | toggle mute             |
| `XF86AudioMicMute` | toggle mic mute       |
| `XF86MonBrightnessUp/Down` | brightness ±  |
| `XF86AudioNext/Prev/Play/Pause` | playerctl |
