# Waybar

GNOME-inspired top bar — same modules a GNOME panel + System Monitor
extension would surface, but rendered by waybar with our own custom
scripts. Themed via `theme set <name>` (palette comes from
`~/.config/waybar/theme.css`, imported by `style.css`).

Config sources:

- [`waybar/.config/waybar/config.jsonc`](../../waybar/.config/waybar/config.jsonc) — module wiring
- [`waybar/.config/waybar/style.css`](../../waybar/.config/waybar/style.css) — layout + colors
- [`themes/<name>/waybar.css`](../../themes/catppuccin-mocha/waybar.css) — palette (per active theme)

## Layout

```
[ Apps  1 ●2 ]  · · · · · · · ·   Sat May 16  10:48 PM   · · · · · · · ·  [󰚰3 󰢮7% 󰍛5% 󰾆21% 󰔏45° 󰈀↑0.1k↓0.2k 󰂯 󰕾 󰃟 󰂁100% 󰂃 |tray| 󰐥]
└──────── left ─────────┘└─────────── center ───────────┘└──────────────────────────── right ────────────────────────────┘
```

### Left (apps + workspaces)

| Slot | Module | Notes |
|---|---|---|
|  Apps | `custom/apps` | wofi launcher button — click opens `wofi --show drun` |
| 1 ●2 | `hyprland/workspaces` | static numbers; ● = active, ○ = inactive |
| (submap) | `hyprland/submap` | only visible when a submap is active |

### Center (clock)

| Slot | Module | Notes |
|---|---|---|
| Sat May 16  10:48 PM | `clock` | weekday + month + day + 12h time; tooltip shows month calendar with today highlighted in pink |

### Right (stats → peripherals → tray → power)

| Glyph | Slot | Source |
|---|---|---|
|  | `custom/ai-usage` | `waybar-ai-usage` AUR — Claude/Codex/Copilot usage; mauve |
| ▶ | `mpris` | built-in MPRIS module — current player + track |
| 󰚰 3 | `custom/updates` | `bin/update check` JSON — pacman+AUR+flatpak+npm+cargo+pipx+uv; sapphire; click → run update |
| 󰍛 5% | `cpu` | built-in; teal |
| 󰾆 21% | `memory` | built-in; sapphire |
| 󰢮 7% | `custom/gpu` | `bin/waybar-gpu` JSON from `/sys/class/drm/card*/device/gpu_busy_percent`; teal/yellow/red |
| 󰔏 45° | `temperature` | built-in (thermal_zone0); peach |
| 󰈀 ↑0.1k ↓0.2k | `network` | built-in with `bandwidthUpBytes`/`bandwidthDownBytes` (3 s interval); blue |
| 󰂯 | `bluetooth` | built-in; click → `bluetui` |
| 󰕾 | `pulseaudio` | built-in (wpctl); volume %; click → mute; right-click → pavucontrol; scroll → ±5 % |
| 󰃟 | `backlight` | built-in (brightnessctl); scroll → ±5 % |
| 󰂁 100% | `battery` | built-in; icon morphs by level |
| 󰂃 | `power-profiles-daemon` | built-in; tooltip shows current profile |
| tray | `tray` | legacy app indicators |
| 󰐥 | `custom/power` | red; click → `bin/power-menu` (wofi power dialog) |

## Why this layout

- **Left** stays minimal — no global menubar (`Apps` is the one launcher trigger).
- **Center** clock balances the bar visually like GNOME's stock.
- **Right** column reads like a status report from left (system load) to
  right (peripherals + battery + power), the same flow GNOME's top bar uses.
- Every right-side pill is a separate `padding: 0 8px` chip with its
  own background-tinted `@bg-alt` pill — visually GNOME-ish without
  copying the macOS dock vibe.

## Modules driven by custom scripts (in `bin/`)

| Waybar module | Script | What it reads / does |
|---|---|---|
| `custom/ai-usage` | `waybar-ai-usage` (AUR pkg) | AI CLI quota usage |
| `custom/updates` | `bin/update check` | Aggregated update count across 6 ecosystems |
| `custom/gpu` | `bin/waybar-gpu` | AMD GPU busy% + VRAM via sysfs |
| `custom/power` | `bin/power-menu` | wofi power dialog |
| `custom/apps` | (inline `wofi --show drun`) | wofi app launcher |

## Theming

Palette comes from `~/.config/waybar/theme.css` (imported by `style.css`).
Changing themes via `theme set <name>` swaps it atomically without
re-stowing.

```bash
theme cycle              # also bound to Super+Ctrl+Alt+Y
```

See [Theming](07-theming.md) for the full theme switcher.

## Refresh

After editing `config.jsonc` or `style.css`:

```bash
pkill -SIGUSR2 waybar    # live-reload, no logout needed
```

If a module isn't appearing after install, check the journal:

```bash
journalctl --user -b -t waybar | tail -50
```

Common gotchas:

- **Custom exec module returning malformed JSON** → entire bar slot
  disappears. Test the script standalone: `bin/waybar-gpu | jq .`
- **Icons render as squares** → install `ttf-jetbrains-mono-nerd`
  (already in `core/base-utils.sh`) and pick the Nerd Font variant in
  Alacritty + waybar's `font-family` (already done in `style.css`).
- **Bluetooth icon hidden** → `bluez` daemon not running →
  `sudo systemctl enable --now bluetooth`.
