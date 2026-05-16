# bin/ scripts

24 standalone scripts shipped via the `bin/` stow package. They live
in `~/.local/bin/` after stowing and are on `$PATH` (see
[`.zshenv`](../../zsh/.zshenv)).

Every script supports `--help`.

## Catalog

| Script           | What it does                                       | Bind                  |
| ---------------- | -------------------------------------------------- | --------------------- |
| `notice`         | On-demand info via `notify-send`                   | `Super+Ctrl+Alt+T/W/B/N/S` |
| `web-app`        | firefoxpwa wrapper for PWAs                        | `Super+Ctrl+G/W/Y/X/Z` |
| `hypr-scale`     | Monitor scale ± via hyprctl                        | `Super+/` / `Super+Alt+/` |
| `power-profile`  | Cycle / set / show powerprofilesctl profile        | `Super+Ctrl+Alt+P`    |
| `power-menu`     | wofi quick power menu                              | `Super+Shift+P`       |
| `clipboard`      | cliphist + wofi/rofi history picker                | `Super+V`             |
| `theme`          | Switch alacritty/waybar/wofi/mako/starship theme   | `Super+Ctrl+Alt+Y`    |
| `screenshot`     | Region/full/window/delay → satty → save            | `Print` / `Super+Print` / `Super+Shift+F` |
| `floating-tui`   | Open `<cmd>` in floating alacritty                 | (used by other binds) |
| `wallpaper`      | hyprpaper: next/prev/random/set/get                | (CLI)                 |
| `emoji`          | Pick emoji via wofi → wl-copy                      | `.` (period)          |
| `unicode`        | Pick arrows/symbols/math via wofi                  | `Super+.`             |
| `dnd`            | Toggle mako Do-Not-Disturb                         | `Super+Ctrl+Alt+D`    |
| `update`         | Snapshot + pacman/AUR/flatpak/npm/cargo/pipx/uv    | (CLI)                 |
| `ocr`            | Region → tesseract → wl-copy                       | `Super+Shift+O`       |
| `record`         | Toggle wf-recorder                                 | `Super+Ctrl+Alt+R`    |
| `night-mode`     | Toggle hyprsunset (3500K)                          | `Super+Ctrl+Alt+M`    |
| `window-finder`  | wofi list of windows → focus                       | `Super+Shift+Tab`     |
| `gamemode-toggle`| Kill animations/blur/idle for gaming               | (CLI)                 |
| `scratch`        | Quake-style scratchpad terminal                    | `Super+grave`         |
| `color-picker`   | hyprpicker hex + notify + history                  | `Super+Shift+C`       |
| `brightness`     | brightnessctl wrapper + mako progress notification | `XF86MonBrightness*`  |
| `volume`         | wpctl wrapper (sink+mic) + mako progress           | `XF86Audio*`          |
| `magnify`        | Hyprland cursor:zoom_factor in/out/toggle/reset    | `Super+=`/`Super+-`/`Super+Shift+M` |

## screenshot

```bash
screenshot region              # slurp → satty → ~/Pictures/screenshots/
screenshot region --copy       # slurp → wl-copy (no save, no annotate)
screenshot full                # entire output → save + notify
screenshot window              # currently focused → save
screenshot delay 5             # sleep 5 then full
```

Files named `YYYYMMDD-HHMMSS.png`. Override target with
`SCREENSHOT_DIR=...`.

## floating-tui

Open any TUI in a floating Alacritty window — used by 6 binds.

```bash
floating-tui lazygit
floating-tui btop
```

The `--class floating-tui` lets you windowrule the spawned window:

```ini
windowrule {
    name = floating-tui-rule
    match:class = floating-tui
    float = yes
    center = 1
    size = 1200 800
}
```

## wallpaper

```bash
wallpaper next              # rotate in $WALLPAPER_DIR (default ~/Pictures/wallpapers)
wallpaper prev
wallpaper random
wallpaper set ~/path.png
wallpaper                   # show current
```

State recorded in `~/.local/share/dotfiles/active-wallpaper`. Applies
to every connected monitor.

## emoji / unicode

Both use `wofi` to pick a glyph. `emoji` downloads the full Unicode
emoji-test.txt on first run (cached in `$XDG_CACHE_HOME/emoji.list` —
`emoji refresh` re-fetches). `unicode` ships an embedded curated list
(arrows, math, box drawing, Greek letters, symbols).

## dnd

Toggles `makoctl mode do-not-disturb`. Notifications keep firing
silently while DND is on — they just don't show.

## update

```bash
update                # default: snapshot + paru -Syu + flatpak + npm + cargo + pipx + uv
update check          # JSON: {count, pacman, aur, flatpak, npm, cargo, pipx, uv, text, tooltip}
update list           # human-readable available updates per ecosystem
```

The `check` output is shaped for a waybar custom module:

```jsonc
"custom/updates": {
    "exec": "update check",
    "return-type": "json",
    "interval": 3600,
    "on-click": "alacritty -e bash -c 'update; sleep 5'"
}
```

Pre-update `snapper -c root create -t single -d "pre-update $(date +%F)"`
runs first if root is btrfs.

## ocr

Pick a region, run tesseract (`eng+por`), copy to clipboard, show
preview. `ocr eng` forces English only; `ocr por` Portuguese only.

## record

Toggle `wf-recorder`. `record region` lets you pick the area first.
Output in `$RECORD_DIR` (default `~/Videos/recordings`).

## night-mode

Toggle `hyprsunset` at `$NIGHT_MODE_TEMP` Kelvin (default 3500).

## window-finder

Wofi list of all clients across workspaces, formatted as
`<workspace>: <class> — <title>`. Selecting one focuses it.

## gamemode-toggle

Disables Hyprland animations, blur, shadow, and idle daemon for the
duration of a gaming session.

```bash
gamemode-toggle           # on/off toggle
gamemode-toggle status    # "on" or "off"
```

## scratch

Toggle a quake-style scratchpad terminal on Hyprland's
`special:scratch` workspace. First call creates one; subsequent calls
show/hide.

## color-picker

`hyprpicker -a -f hex` — copies hex code, appends to history at
`~/.local/share/dotfiles/color-history`.

## brightness / volume

Custom replacements for `swayosd-client`. Notifications use mako's
progress hint (`int:value:N`) for a native bar visual — no
`swayosd-server` daemon needed.

```bash
brightness raise|lower|set <N>|get
volume raise|lower|mute-toggle|mic-mute-toggle|set <N>|get
```

Multimedia keys are bound to these in `hyprland/bindings.conf`.

## magnify

```bash
magnify in              # +0.5x (default step; override $MAGNIFY_STEP)
magnify out             # -0.5x
magnify toggle          # 1.0 ↔ 1.5
magnify reset           # back to 1.0
magnify set 2.0         # absolute
```

Clamped to `[1.0, 3.0]`. Uses `hyprctl keyword cursor:zoom_factor`.

## Adding new scripts

1. Drop the executable into `bin/.local/bin/<name>`.
2. `chmod +x bin/.local/bin/<name>`.
3. Re-stow: `cd ~/dotfiles && stow -R -t ~ bin`.
4. (Optional) document here.

`dev/stow.sh` and `dev/alacritty.sh` apply the stow automatically on
re-run.
