# GNOME extensions

The recommended extension list lives in
[`scripts/arch/desktop/gnome-extensions.txt`](../../scripts/arch/desktop/gnome-extensions.txt).

GNOME breaks extension compatibility between Shell versions, so this
repo **does not auto-install** extensions — install via Extension
Manager and the list serves as documentation of the intended setup.

## How to install (recommended)

```bash
# Extension Manager — graphical install from extensions.gnome.org
extension-manager
```

For each UUID in the list: search by name in Extension Manager → install.

## CLI alternative

If you prefer scripting (acknowledging the version-coupling risk):

```bash
# Helper from AUR
paru -S gnome-shell-extension-installer

# Install everything in the list (skips comments)
grep -E '^[a-z]' scripts/arch/desktop/gnome-extensions.txt \
    | while read ext; do
        gnome-shell-extension-installer --yes "$ext"
      done
```

After install, **log out and back in** for GNOME Shell to pick up new
extensions, then enable them via Extension Manager.

## Visual extensions

| Extension                     | UUID                                              | Why                                                |
| ----------------------------- | ------------------------------------------------- | -------------------------------------------------- |
| Blur My Shell                 | `blur-my-shell@aunetx`                            | Blur on top bar, overview, dash, panels            |
| Dash to Dock                  | `dash-to-dock@micxgx.gmail.com`                   | Always-visible dock; floating, autohide, position  |
| Just Perfection               | `just-perfection-desktop@just-perfection`         | Hide/show every UI element in GNOME Shell granularly |
| Rounded Window Corners Reborn | `rounded-window-corners@fxgn`                     | Rounded corners on any window (Wayland-compatible) |
| User Themes                   | `user-theme@gnome-shell-extensions.gcampax.github.com` | Required to load custom shell theme           |

## Workflow extensions

| Extension                  | UUID                                  | Why                                                  |
| -------------------------- | ------------------------------------- | ---------------------------------------------------- |
| AppIndicator Support       | `appindicatorsupport@rgcjonas.gmail.com` | Brings legacy tray icons back (Discord, Telegram, …) |
| Caffeine                   | `caffeine@patapon.info`                | Keep screen awake during long tasks                 |
| Clipboard History          | `clipboard-history@alexsaveau.dev`     | History panel for the clipboard                     |
| GSConnect                  | `gsconnect@andyholmes.github.io`       | KDE Connect for GNOME — phone integration           |
| Quick Settings Tweaker     | `quick-settings-tweaks@qwreey`         | Customise the Quick Settings menu                   |
| Space Bar                  | `space-bar@luchrioh`                   | i3-style workspace indicator in the top bar         |
| Tiling Shell               | `tilingshell@ferrarodomenico.com`      | i3/Hyprland-like tiling with snap zones             |

## Optional / mutually exclusive

Don't enable all of these at once — they collide:

- **`burn-my-windows@schneegans.github.com`** — close/open animations (fire, dissolve, …)
- **`compiz-windows-effect@hermes83.github.com`** — wobbly window drag
- **`desktop-cube@schneegans.github.com`** — workspace cube transition
- **`forge@jmmaranan.com`** — alternate tiling (conflicts with Tiling Shell)
- **`paperwm@paperwm.github.com`** — scrolling-workspaces workflow

Pick **one** tiling extension (Tiling Shell recommended). Eye-candy
extensions can stack but might cost frames on the AMD GPU.

## After installing

Re-run [`desktop/gnome-rice.sh`](../../scripts/arch/desktop/gnome-rice.sh)
— it re-applies the gsettings that some extensions reset.

```bash
./scripts/arch/arch.sh desktop/gnome-rice
```
