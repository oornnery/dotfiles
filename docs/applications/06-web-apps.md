# Web Apps

Site-isolated browser windows for web services you use as apps (ChatGPT,
WhatsApp Web, X, YouTube, Zoom). Backed by [PWAs for
Firefox](https://github.com/filips123/PWAsForFirefox) — a native helper
that wraps any URL as a standalone profile + window.

## Setup (one-time)

```bash
./scripts/arch/arch.sh core/firefoxpwa     # installs firefox + firefoxpwa (AUR)
```

Then open Firefox and install the matching extension:
<https://addons.mozilla.org/firefox/addon/pwas-for-firefox/>.
The extension handshakes with `firefoxpwa` and unlocks "Install web app"
in the URL bar menu.

## Adding a PWA

Either through the extension UI (right-click → "Install this site as an
app") or via the CLI wrapper [`bin/.local/bin/web-app`](../../../bin/.local/bin/web-app):

```bash
web-app install https://chat.openai.com chatgpt
web-app install https://web.whatsapp.com whatsapp
web-app install https://x.com x
web-app install https://youtube.com youtube
web-app install https://zoom.us zoom
```

`web-app list` shows what's installed; `web-app remove <name>` deletes one.

## Hyprland binds

```ini
# hyprland/.config/hypr/bindings.conf
bind = $mainMod CTRL, G, exec, web-app launch chatgpt
bind = $mainMod CTRL, W, exec, web-app launch whatsapp
bind = $mainMod CTRL, Y, exec, web-app launch youtube
bind = $mainMod CTRL, X, exec, web-app launch x
bind = $mainMod CTRL, Z, exec, web-app launch zoom
```

Each runs in its own Firefox profile — you stay logged in independently
of the main browser session. Cookies, bookmarks, extensions: isolated.

## Why not Chromium `--app=`?

Equivalent in spirit, but firefoxpwa gives:

- True profile isolation (separate `.mozilla/firefox/<id>` dir)
- Desktop integration: `.desktop` file in `~/.local/share/applications/`
  → shows up in wofi/menu
- Manifest + icons fetched from the site
- One install, multiple launches — no flag soup

Trade-off: needs the AUR pkg + extension; Chromium `--app=` works
out-of-box. Pick your poison.
