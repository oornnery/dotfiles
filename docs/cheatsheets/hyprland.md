# Hyprland Cheatsheet

Hyprland 0.55+ with config in **Lua** (`~/.config/hypr/lua/`). Bindings live in
`bindings.lua`, autostart in `autostart.lua`, window rules in `windowrules.lua`.

> Mods: `M = Super` · `MS = Super+Shift` · `MC = Super+Ctrl` ·
> `MCA = Super+Ctrl+Alt` · `MA = Super+Alt` · `MSA = Super+Shift+Alt`

## Apps

| Bind         | Action                                  |
| ------------ | --------------------------------------- |
| `M + Return` | Terminal (alacritty)                    |
| `M + E`      | File manager (nautilus)                 |
| `M + R`     | Launcher (walker)                       |
| `M + B`     | Browser (firefox)                       |
| `M + L`     | Lock screen (hyprlock)                  |
| `MS + P`    | Power menu (lock/suspend/logout/reboot/shutdown) |
| `M + M`     | Exit Hyprland                           |
| `M + grave` | Scratchpad terminal (`scratch`)         |

## Window management

| Bind           | Action                                |
| -------------- | ------------------------------------- |
| `MS + Q`       | Close window                          |
| `M + T`        | Toggle floating (T = tile/float)      |
| `M + P`        | Pseudo tile                           |
| `M + J`        | Toggle split (dwindle)                |
| `M + F`        | Fullscreen                            |
| `M + ←/→/↑/↓`  | Focus left / right / up / down        |
| `MS + ←/→/↑/↓` | Move window left/right/up/down (swap) |
| `M + LMB`      | Drag floating window                  |
| `M + RMB`      | Resize floating window                |
| `MS + Tab`     | Window finder (`walker -m windows`)   |

## Workspaces

| Bind              | Action                                  |
| ----------------- | --------------------------------------- |
| `M + 1..9, 0`     | Switch to workspace 1..10               |
| `MS + 1..9, 0`    | Move window to workspace 1..10          |
| `M + S`           | Toggle special workspace (scratchpad)   |
| `MS + S`          | Move window to scratchpad               |
| `M + scroll up`   | Previous workspace                      |
| `M + scroll down` | Next workspace                          |

## Screenshots / OCR

| Bind         | Action                        |
| ------------ | ----------------------------- |
| `Print`      | Screenshot region (saved)     |
| `M + Print`  | Screenshot full (saved)       |
| `MS + F`     | Screenshot region → clipboard |
| `MC + Print` | Screenshot window             |
| `MS + O`     | OCR region → clipboard        |

## Pickers (walker + clipboard)

| Bind     | Action                                    |
| -------- | ----------------------------------------- |
| `M + V`  | Clipboard history (`walker -m clipboard`) |
| `MS + C` | Color picker (hex → clipboard)            |
| `M + .`  | Emoji / symbols (`walker -m symbols`)     |
| `MS + .` | Emoji / symbols (alias)                   |

## Floating TUIs

`floating-tui <cmd>` opens alacritty with `--class floating-tui` (centered 1000×700).

| Bind      | TUI        | What             |
| --------- | ---------- | ---------------- |
| `MS + G`  | lazygit    | Git TUI          |
| `MS + D`  | lazydocker | Docker TUI       |
| `MS + T`  | btop       | System monitor   |
| `MS + B`  | bluetui    | Bluetooth TUI    |
| `MS + W`  | impala     | Wi-Fi TUI        |
| `MS + A`  | pacsea     | Arch package TUI |
| `MSA + M` | cliamp     | Music TUI        |

## Web apps (firefoxpwa)

| Bind     | Web app     |
| -------- | ----------- |
| `MC + G` | ChatGPT     |
| `MC + W` | WhatsApp    |
| `MC + Y` | YouTube     |
| `MC + X` | X (Twitter) |
| `MC + Z` | Zoom        |

## Notices (on-demand notify-send)

| Bind      | Notice      |
| --------- | ----------- |
| `MCA + T` | Date / time |
| `MCA + W` | Weather     |
| `MCA + B` | Battery     |
| `MCA + N` | Network     |
| `MCA + S` | System info |

## Monitor scale + magnify

| Bind     | Action             |
| -------- | ------------------ |
| `M + /`  | Monitor scale +0.1 |
| `MA + /` | Monitor scale -0.1 |
| `M + =`  | Magnify in         |
| `M + -`  | Magnify out        |
| `MS + M` | Magnify toggle     |

## Themes / power / state toggles

| Bind         | Action                          |
| ------------ | ------------------------------- |
| `MCA + Y`    | Cycle theme                     |
| `MCA + P`    | Cycle power profile             |
| `MCA + D`    | Toggle DND                      |
| `MCA + M`    | Toggle night mode               |
| `MCA + R`    | Screen record                   |
| `MCA + G`    | Toggle gaps                     |
| `MCA + O`    | Toggle transparency             |
| `MCA + L`    | Cycle layout (dwindle / master) |
| `MCA + C`    | Toggle monitor mirror           |
| `MA + Space` | Cycle keyboard layout           |

## Helpers

| Bind     | Action                   |
| -------- | ------------------------ |
| `MS + H` | Cheatsheet (all sources) |
| `M + N`  | Obsidian: today's note   |
| `MS + N` | Obsidian: find note      |
| `MC + N` | Obsidian: search         |

## Notifications (mako)

| Bind             | Action                                    |
| ---------------- | ----------------------------------------- |
| `M + Backspace`  | Dismiss all visible notifications         |
| `MS + Backspace` | Restore last expired (history buffer)     |
| `MC + Backspace` | Pick from active list (walker)            |
| `MCA + D`        | Toggle Do-Not-Disturb (`dnd` script)      |

Mouse on a notification popup:
- **Left** → invoke default action (e.g. open update terminal)
- **Middle** → dismiss this one
- **Right** → dismiss all visible

## Multimedia (no-mod, repeating + locked)

| Key                     | Action              |
| ----------------------- | ------------------- |
| `XF86AudioRaiseVolume`  | Volume up           |
| `XF86AudioLowerVolume`  | Volume down         |
| `XF86AudioMute`         | Mute toggle         |
| `XF86AudioMicMute`      | Mic mute toggle     |
| `XF86MonBrightnessUp`   | Brightness up       |
| `XF86MonBrightnessDown` | Brightness down     |
| `XF86AudioNext`         | Media: next         |
| `XF86AudioPrev`         | Media: previous     |
| `XF86AudioPlay/Pause`   | Media: play / pause |

## bin/ helpers used by the binds

| Script                       | What it does                                  |
| ---------------------------- | --------------------------------------------- |
| `screenshot`                 | region / full / window / `--copy`             |
| `record`                     | wf-recorder / gpu-screen-recorder wrapper     |
| `ocr`                        | grim → tesseract → wl-copy                    |
| `color-picker`               | hyprpicker → hex → clipboard                  |
| `volume`                     | raise / lower / mute-toggle / mic-mute-toggle |
| `brightness`                 | raise / lower                                 |
| `magnify`                    | in / out / toggle                             |
| `notice`                     | date · weather · battery · network · system   |
| `theme`                      | list / set `<name>` / cycle                   |
| `power-profile`              | cycle / set                                   |
| `power-menu`                 | wlogout-style menu                            |
| `dnd`                        | Toggle Do Not Disturb (mako)                  |
| `night-mode`                 | hyprsunset toggle                             |
| `floating-tui <cmd>`         | Spawn TUI floating, centered                  |
| `web-app launch <name>`      | firefoxpwa launcher                           |
| `scratch`                    | Scratchpad terminal toggle                    |
| `obsidian-note today/find/…` | Quick Obsidian helpers                        |
| `hypr-scale +0.1/-0.1`       | Monitor scale up / down                       |
| `hypr-gaps-toggle`           | Toggle gaps                                   |
| `hypr-transparency-toggle`   | Toggle window opacity                         |
| `hypr-layout-toggle`         | Cycle dwindle ↔ master                        |
| `hypr-monitor-mirror toggle` | Mirror eDP → HDMI (presentations)             |

## dots- CLI (cheatsheet, menus, hooks)

| Command                        | What                                   |
| ------------------------------ | -------------------------------------- |
| `dots`                         | List all available verbs               |
| `dots help <verb>`             | Per-verb help                          |
| `dots cheatsheet`              | This menu (Hyprland/Tmux/Vim/Zsh/MDs)  |
| `dots menu-keybindings`        | Walker picker over all binds (live)    |
| `dots notification-send …`     | mako/dunst wrapper                     |
| `dots state get/set/toggle`    | Persistent kv (JSON in `~/.local/state`)|
| `dots launch-or-focus <class>` | Spawn or focus existing window         |
| `dots reminder add/list/…`     | Reminder service                       |
| `dots screensaver`             | Idle activator                         |
| `dots hook list/run`           | Hyprland event hooks                   |

## Active window rules

| Match (class/title)            | Effect                                     |
| ------------------------------ | ------------------------------------------ |
| `.*`                           | Suppress maximize events                   |
| `floating-tui`                 | float + center + 1000×700                  |
| `floating`                     | float + center + 900×600                   |
| `floating-md`                  | float + center + 900×800 + 0.98/0.95 opacity (cheatsheet docs) |
| `hyprland-run`                 | float + move to bottom                     |
| `Astal Launcher` / `Launcher`  | float + center + 620×430 + no shadow       |
| `satty`                        | float + center + 1200×800 (screenshot annotator) |
| Browser (Firefox/Vivaldi/…) dialogs | float + center + 900×650 (file picker, sign-in, print, PiP, …) |
| `FFPWA-*` PWA popups           | float + center + 600×500 (web app auth/PiP) |
| `xdg-desktop-portal-*`         | float + center (system file picker, screen share prompts) |
| Generic `Confirm`/`Alert`/`Prompt`/`.*Dialog` titles | float + center |

## Reactive events (events.lua)

| Event               | What happens                   |
| ------------------- | ------------------------------ |
| `monitor.added`     | notify-send + `hyprctl reload` |
| `screenshare.state` | notify-send (start/stop)       |
| `config.reloaded`   | notify-send confirm            |
| `hyprland.shutdown` | Save state via `dots-state`    |

## Tips

| Tip                                            | Why it helps                              |
| ---------------------------------------------- | ----------------------------------------- |
| Bindings carry `description` (kb helper)       | `hyprctl binds -j` returns readable text  |
| Walker `-m <provider>` replaces wofi pickers   | One launcher for everything               |
| `floating-md` class → 900×800 reading window   | Cheatsheets render comfortably            |
| `DOTS_MD_VIEWER=glow\|bat\|rich\|auto`         | Per-call markdown renderer choice         |
| `prefix=Super` everywhere (Q/E/R/B/L/M…)       | Consistent muscle memory                  |
| `MS + H` opens the cheatsheet (this file)      | Self-referential — always reachable       |
