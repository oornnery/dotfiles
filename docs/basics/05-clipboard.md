# Clipboard & History

Wayland-native clipboard via [`wl-clipboard`](https://github.com/bugaevc/wl-clipboard);
history via [`cliphist`](https://github.com/sentriz/cliphist).

## Wiring

Both `wl-paste --watch cliphist store` daemons (one for text, one for
images) start automatically — see [`hyprland.conf`](../../../hyprland/.config/hypr/hyprland.conf)
autostart block. Every copy goes into a local SQLite history.

## Usage

```bash
echo hello | wl-copy            # programmatic copy
wl-paste                        # read clipboard
cliphist list                   # history
cliphist list | cliphist decode # full content of latest entry
```

## Hyprland bind

| Bind        | Action                                                |
| ----------- | ----------------------------------------------------- |
| `Super + V` | `cliphist list \| wofi --dmenu \| cliphist decode \| wl-copy` |

Pick an entry in the wofi prompt → it's set as the current clipboard
contents → paste anywhere.

## Wipe history

```bash
cliphist wipe                   # clear everything
```
