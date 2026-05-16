# Monitors

Hyprland's monitor config lives in
[`hyprland/.config/hypr/monitors.conf`](../../../hyprland/.config/hypr/monitors.conf),
sourced from `hyprland.conf`. Edit, save, then `hyprctl reload` — no
session restart.

## Current layout

```ini
monitor = eDP-1, preferred, 0x0, 1.2          # VAIO internal, 1.2× scale
monitor = HDMI-A-1, preferred, 1600x0, 1      # external to the right
monitor = , preferred, auto, 1                # catch-all fallback
```

## Format

```text
monitor = NAME, RESOLUTION@HZ, POSITION_x_y, SCALE [, transform, mirror, vrr]
```

| Field    | Examples                                         |
| -------- | ------------------------------------------------ |
| NAME     | `eDP-1` / `HDMI-A-1` / `DP-1` / `desc:Pattern`   |
| RESOLUTION | `1920x1080@60` / `preferred` / `highres`       |
| POSITION | `0x0` / `auto` / `auto-right` / `1600x0`         |
| SCALE    | `1.0` / `1.2` / `1.5` (fractional supported)     |

Live preview without persisting:

```bash
hyprctl keyword monitor eDP-1,preferred,0x0,1.5
```

If you like the new value, paste it into `monitors.conf` and reload.

## Scaling hotkeys

Driven by [`bin/.local/bin/hypr-scale`](../../../bin/.local/bin/hypr-scale).
It bumps the focused monitor's scale, clamped to `[0.8, 3.0]`.

| Bind             | Action                |
| ---------------- | --------------------- |
| `Super + /`      | scale +0.1            |
| `Super + Alt + /`| scale -0.1            |

Set an absolute value from a shell:

```bash
hypr-scale =1.5
```

A `notify-send` confirms the new value.

## Useful commands

| Goal                              | Command                                          |
| --------------------------------- | ------------------------------------------------ |
| List monitors + capabilities      | `hyprctl monitors`                               |
| JSON view (for scripting/jq)      | `hyprctl monitors -j \| jq`                      |
| Disable a monitor                 | `hyprctl keyword monitor NAME,disable`           |
| Mirror onto another               | `monitor = NAME, preferred, auto, 1, mirror, eDP-1` |
| Force a 90° rotation              | `monitor = NAME, preferred, auto, 1, transform, 1` |

## Hot-plug

Hyprland reacts to monitor connect/disconnect events. If the catch-all
line (`monitor = , preferred, auto, 1`) is present, new displays get
placed to the right of `eDP-1` at native resolution. Override per-output
by adding an explicit `monitor = <name>, …` line above the catch-all.
