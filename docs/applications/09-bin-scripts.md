# bin/ scripts

Seven standalone scripts shipped via the `bin/` stow package. They live
in `~/.local/bin/` after stowing and are on `$PATH` (see
[`.zshenv`](../../zsh/.zshenv)).

## Catalog

| Script        | What it does                                        |
| ------------- | --------------------------------------------------- |
| [notice](../basics/06-notices.md) | On-demand info via `notify-send` |
| [web-app](06-web-apps.md)         | firefoxpwa wrapper for PWAs       |
| [hypr-scale](../configuration/01-monitors.md) | Monitor scale ± via hyprctl |
| `power-profile` | Cycle / set / show `powerprofilesctl` profile     |
| `power-menu`    | wofi quick power menu (lock/suspend/logout/reboot/shutdown) |
| `clipboard`     | `cliphist` history via wofi or rofi               |
| [theme](../configuration/07-theming.md) | Switch visual theme across apps |

## power-profile

```bash
power-profile             # show current profile + notify
power-profile cycle       # power-saver → balanced → performance
power-profile set balanced
power-profile list
```

Bound to `Super + Ctrl + Alt + P` (cycle).

## power-menu

```bash
power-menu                # opens wofi with 5 options
```

Reboot and Shutdown ask for second-step confirmation through wofi.

Bound to `Super + Shift + P` (keyboard-first). For the rich, icon-based
GUI, `Super + Shift + E` opens `wlogout` instead.

## clipboard

```bash
clipboard                 # pick from history (wofi) and paste back
clipboard wipe            # clear history
CLIPBOARD_PICKER=rofi clipboard   # use rofi instead of wofi
```

Bound to `Super + V`. Replaces the inline `cliphist | wofi …`
pipeline that used to live in `bindings.conf`.

## theme

```bash
theme list                  # available themes (* marks current)
theme get                   # current
theme set tokyo-night       # activate by name
theme cycle                 # rotate to the next theme
```

Bound to `Super + Ctrl + Alt + Y` (cycle). Switches alacritty, waybar,
wofi, mako and starship in one shot. See [Theming](../configuration/07-theming.md)
for how it works and how to add a theme.

## Adding new scripts

1. Drop the executable into `bin/.local/bin/<name>`.
2. `chmod +x bin/.local/bin/<name>`.
3. Re-stow: `cd ~/dotfiles && stow -R -t ~ bin`.
4. (Optional) document here.

The package is also auto-stowed by `dev/stow.sh`, so the next bootstrap
run picks new scripts up.
