# Walker Cheatsheet

The active app launcher / dmenu / picker. Replaces wofi for most pickers in
this dotfiles repo. Config lives in `~/.config/walker/`.

## Launching

| Command                  | What it does                                 |
| ------------------------ | -------------------------------------------- |
| `walker`                 | Open default launcher (apps)                 |
| `walker -m <module>`     | Open a specific module                       |
| `walker --dmenu`         | Read entries from stdin (dmenu mode)         |
| `walker --dmenu --placeholder 'Pick:'` | dmenu with custom prompt        |
| `walker --quit`          | Quit running daemon                          |

## Tab strip (visual reminder above results)

A horizontal row of provider chips is rendered between the search box and
the results list. They're **not clickable** (walker doesn't wire layout
buttons to provider switching), but show every prefix at a glance:

```
[  apps] [  = calc] [  > run] [  : clip] [  . sym] [󰂯 # bt]
[  / files] [  $ win] [  @ web] [  ? pkg]
```

Style + content live in `walker/.config/walker/themes/default/{layout.xml,style.css}`.

## Modules (`-m <name>`)

| Module            | What it picks                    |
| ----------------- | -------------------------------- |
| `desktopapplications` | Installed `.desktop` apps    |
| `runner`          | Arbitrary command                |
| `clipboard`       | Clipboard history (via cliphist) |
| `symbols`         | Emoji + unicode symbols          |
| `windows`         | Open windows (Hyprland clients)  |
| `files`           | File browser                     |
| `calc`            | Calculator                       |
| `websearch`       | Search engines / URLs            |
| `bluetooth`       | Paired devices (connect/disconnect) |
| `playerctl`       | MPRIS player control             |
| `bookmarks`       | Browser bookmarks                |
| `archlinuxpkgs`   | Search Arch package DB           |
| `todo` / `snippets` | Lists from elephant providers  |
| `providerlist`    | Picker of all providers (meta)   |

## Keybinds bound in this repo (Hyprland)

| Bind        | Walker action                                 |
| ----------- | --------------------------------------------- |
| `M + R`     | `walker` (default — apps+calc+clip+sym+BT+pl) |
| `M + space` | `walker -m providerlist` (provider picker)    |
| `MS + Tab`  | `walker -m windows` (window finder)           |
| `M + V`     | `walker -m clipboard`                         |
| `M + .`     | `walker -m symbols` (emoji)                   |
| `MS + .`    | `walker -m symbols` (alias)                   |
| `M + I`     | `llm` (picker for claude/codex/…)             |

## Prefix shortcuts inside walker

Type a prefix character first to filter to one provider:

| Prefix | Provider          | Use                                    |
| ------ | ----------------- | -------------------------------------- |
| `;`    | providerlist      | Pick which provider to use             |
| `>`    | runner            | Run a shell command                    |
| `/`    | files             | File browser                           |
| `.`    | symbols           | Emoji / unicode                        |
| `!`    | todo              | Todo list                              |
| `=`    | calc              | Calculator (`= 1+2*3`)                 |
| `@`    | websearch         | Web search                             |
| `:`    | clipboard         | Clipboard history                      |
| `$`    | windows           | Open Hyprland windows                  |
| `?`    | archlinuxpkgs     | Arch package search                    |
| `#`    | bluetooth         | Paired devices                         |
| `%`    | bookmarks         | Browser bookmarks                      |
| `&`    | playerctl         | Media players (MPRIS)                  |

## Daemon mode

```bash
# Start (autostarted via Hyprland exec-once normally)
walker --gapplication-service

# Status
pgrep -af walker

# Restart (after config change)
pkill walker && walker --gapplication-service &
```

## dmenu mode (for scripts)

```bash
# Pipe options in, get pick back
choice=$(printf 'one\ntwo\nthree\n' | walker --dmenu --placeholder 'Pick:')
echo "you picked: $choice"

# Quit on empty (Esc):
[[ -z "$choice" ]] && exit 0

# Used by:
#   dots-cheatsheet         (cheatsheet picker)
#   dots-menu-keybindings   (live keybinding picker)
#   power-menu              (still uses wofi — being migrated)
```

## Keybinds inside walker

| Key              | Action                       |
| ---------------- | ---------------------------- |
| `Type`           | Filter entries (fuzzy match) |
| `↑` / `↓`        | Move selection               |
| `Ctrl-j` / `Ctrl-k` | Move selection (vim-style)|
| `Enter`          | Activate                     |
| `Esc`            | Cancel                       |
| `Ctrl-Enter`     | Run alternative action       |
| `Tab`            | Complete / cycle             |
| `Ctrl-Shift-c`   | Copy entry                   |

> Exact binds depend on your `~/.config/walker/config.toml` keys section.

## Config (`~/.config/walker/config.toml`)

```toml
[app_launch_prefix]
# e.g. type "= 1+1" → runs calc instead of search
calc = "="
runner = "$"
websearch = "?"

[modules.applications]
hidden = ["org.gnome.zenity"]  # Hide specific desktop entries

[modules.symbols]
exec = "wl-copy"  # On select, copy to clipboard

[themes]
default = "default"
```

## Troubleshooting

| Symptom                    | Fix                                                |
| -------------------------- | -------------------------------------------------- |
| Slow first open            | Daemon not running — start with `--gapplication-service` |
| Old apps showing           | `update-desktop-database ~/.local/share/applications` |
| Theme not applied          | Restart daemon (`pkill walker && walker -g…`)      |
| Clipboard module empty     | `cliphist` not running — check `cliphist store` is autostart |
| Window module misses some  | Restart compositor or `walker --quit && walker -g…`|

## walker vs wofi (this repo's migration)

| Aspect       | walker                          | wofi                          |
| ------------ | ------------------------------- | ----------------------------- |
| Modules      | Built-in pickers                | Each is a separate `--show X` |
| Daemon       | Yes, fast subsequent opens      | No — slower on each call      |
| Theming      | TOML + CSS                      | CSS only                      |
| Used in repo | All current `dots-*` pickers    | `power-menu` (legacy)         |
| Legacy refs  | `wofi/scripts/*` (parked)       | `wofi/.config/wofi/`          |

## Tips

| Tip                                              | Why it helps                          |
| ------------------------------------------------ | ------------------------------------- |
| Run as daemon (`--gapplication-service`)         | Sub-50ms open time                    |
| `--dmenu` makes walker scriptable                | One picker for everything             |
| Use prefixes (`=`, `$`, `?`) for instant routes  | Skip the module switch                |
| Restart daemon after config changes              | TOML isn't hot-reloaded               |
| `walker -m windows` > Hyprland's built-in        | Fuzzy match by class/title            |
