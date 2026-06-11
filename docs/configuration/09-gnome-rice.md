# GNOME rice

A "premium GNOME" setup: keeps GNOME's stability and design language,
adds blur, dock, rounded corners, dark theme, WM-like keybindings, and
a tiling extension. **Not a macOS clone** — GNOME with a modern coat.

The script: [`scripts/arch/desktop/gnome-rice.sh`](../../scripts/arch/desktop/gnome-rice.sh)
The extension list: [`scripts/arch/desktop/gnome-extensions.txt`](../../scripts/arch/desktop/gnome-extensions.txt)

## Run

```bash
sudo bash scripts/arch/desktop/gnome-rice.sh
# or via the menu:
./scripts/arch/arch.sh desktop/gnome-rice
```

Idempotent — re-running re-applies gsettings (handy after installing
new extensions or changing the profile).

## Config

```bash
# scripts/arch/arch.conf
ENABLE_GNOME_RICE=1
GNOME_RICE_PROFILE="modern"   # minimal | modern | wm-like
```

| Profile     | What changes                                                    |
| ----------- | --------------------------------------------------------------- |
| `minimal`   | Install theming packages; skip mutter tweaks. Closest to vanilla. |
| `modern`    | Recommended. Polish + Super+1..9 workspaces + screenshot binds. |
| `wm-like`   | Fixed 10 workspaces, more keyboard-driven, less click-to-do.    |

## What it installs

**pacman:**
`gnome-tweaks`, `gnome-shell-extensions`, `gnome-browser-connector`,
`dconf-editor`, `extension-manager`, `xdg-desktop-portal-gnome`,
`libadwaita`, `adw-gtk-theme`, `papirus-icon-theme`, `wl-clipboard`,
`cliphist`, `grim`, `slurp`, `swappy`, `brightnessctl`, `playerctl`,
`pavucontrol`, `fastfetch`.

**AUR via paru (optional):**
`gradience`, `bibata-cursor-theme-bin`, `morewaita-icon-theme`.

If `paru` is missing, the AUR step is skipped with a warning (the rest
still runs).

## What it changes (gsettings)

### Interface

| Key                         | Value                              |
| --------------------------- | ---------------------------------- |
| `color-scheme`              | `prefer-dark`                      |
| `gtk-theme`                 | `adw-gtk3-dark`                    |
| `icon-theme`                | `Papirus-Dark`                     |
| `cursor-theme`              | `Bibata-Modern-Ice`                |
| `font-name`                 | `Inter 10`                         |
| `document-font-name`        | `Inter 10`                         |
| `monospace-font-name`       | `JetBrainsMono Nerd Font 10`       |
| `clock-show-seconds`        | `false`                            |
| `clock-show-weekday`        | `true`                             |
| `show-battery-percentage`   | `true`                             |
| `enable-animations`         | `true`                             |

### Mutter / WM behaviour

| Key                            | Value                                       |
| ------------------------------ | ------------------------------------------- |
| `center-new-windows`           | `true`                                      |
| `dynamic-workspaces`           | `true` (false in `wm-like` profile)         |
| `edge-tiling`                  | `true`                                      |
| `workspaces-only-on-primary`   | `false`                                     |
| `button-layout`                | `appmenu:minimize,maximize,close`           |

### Nautilus

| Key                       | Value          |
| ------------------------- | -------------- |
| `default-folder-viewer`   | `list-view`    |
| `default-zoom-level`      | `small`        |
| `default-sort-order`      | `type`         |
| `show-create-link`        | `true`         |
| `show-hidden-files`       | `false`        |

### Keybindings (WM-like)

| Bind                       | Action                          |
| -------------------------- | ------------------------------- |
| `Super + 1..9`             | switch to workspace 1..9        |
| `Super + Shift + 1..9`     | move window to workspace 1..9   |
| `Super + Return`           | open terminal                   |
| `Super + Shift + S`        | screenshot UI (region)          |
| `Print`                    | screenshot UI                   |
| `Super + L`                | lock screen                     |

## What it does NOT do

- **Install GNOME extensions** — that's manual via Extension Manager.
  Auto-installing breaks frequently between GNOME Shell versions; the
  curated list in [`gnome-extensions.txt`](../../scripts/arch/desktop/gnome-extensions.txt)
  is the source of truth instead.
- **Stow `~/.config/gnome-*`** — GNOME stores most state in dconf, not
  files. dconf has its own backup workflow (`dconf dump /` /
  `dconf load /`).
- **Set a wallpaper** — depends on personal taste; use Settings → Appearance,
  or `gsettings set org.gnome.desktop.background picture-uri-dark file://…`.

## Pairing with Hyprland

Both DEs coexist on this machine — GDM lets you pick the session at
the login screen. Things that already work in both:

- Shell (zsh + OMZ + plugins + theme)
- Terminal (alacritty with theme.toml)
- Editor (nvim or nvim-lazy)
- Tools (`bin/notice`, `bin/clipboard`, `bin/theme`, `bin/web-app`, …)
- Theme switcher (alacritty + waybar + wofi + mako + starship — Hyprland
  side; GNOME uses gsettings)
- Wallpapers (each DE picks its own; centralise via `~/Pictures/wallpapers`)

GNOME = daily driver. Hyprland = focused/tiling sessions.

## Resetting

To roll back the rice without reinstalling GNOME:

```bash
dconf reset -f /org/gnome/desktop/interface/
dconf reset -f /org/gnome/mutter/
dconf reset -f /org/gnome/desktop/wm/
```

Pacman packages stay (no harm). Re-run `desktop/gnome-rice.sh` to
re-apply.
