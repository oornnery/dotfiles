# Notices

On-demand info via `notify-send`, surfaced through `mako` (already in
Hyprland autostart). Driven by a single script: [`bin/.local/bin/notice`](../../../bin/.local/bin/notice).

## Hotkeys

| Bind                      | Topic       | What it shows                                            |
| ------------------------- | ----------- | -------------------------------------------------------- |
| `Super + Ctrl + Alt + T`  | date        | `notice date`        — calendar + clock                  |
| `Super + Ctrl + Alt + W`  | weather     | `notice weather`     — `wttr.in/$WEATHER_CITY`           |
| `Super + Ctrl + Alt + B`  | battery     | `notice battery`     — charge % + status (acpi)          |
| `Super + Ctrl + Alt + N`  | network     | `notice network`     — active NM connections             |
| `Super + Ctrl + Alt + S`  | system      | `notice system`      — uptime, load, RAM                 |

Volume / brightness use a different OSD (swayosd-client, on multimedia keys)
because those need live feedback while you hold the key. Notices are
one-shot pull queries.

## Configuration

```bash
# scripts/arch/arch.conf
WEATHER_CITY="Salvador"     # → curl wttr.in/Salvador
```

Change the city, re-source `arch.conf`, and the next `notice weather` uses
the new value (no Hyprland reload needed).

## CLI usage

```bash
notice date              # one-off, prints nothing to stdout
notice weather           # uses wttr.in via curl
notice help              # list topics
```

## Dependencies

- `libnotify` (notify-send)
- `acpi` (battery)
- `curl` (weather)
- `nmcli` (network — optional, falls back to `ip`)
- `wpctl`, `brightnessctl` (volume/brightness)

All shipped via [core/base-utils.sh](../../../scripts/arch/core/base-utils.sh).
