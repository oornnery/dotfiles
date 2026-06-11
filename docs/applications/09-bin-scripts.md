# The `dots` CLI

Everything that used to be a standalone `~/.local/bin/<name>` script is now a
**single command**: `dots <group> <action>`. Only `dots` lives on `$PATH`; the
per-group modules live in `~/.local/lib/dots/` and are reached through it.

```bash
dots                      # context-aware picker (walker in WM, fzf in terminal)
dots <group> [args…]      # run a command, e.g. dots theme set tokyo-night
dots --help               # usage + grouped command list
dots commands             # just the group names
```

## How it adapts to context

- **Picker** (`dots menu`, used by `dots`, `dots help`, pickers): inside tmux →
  `fzf --tmux` popup; in a terminal → `fzf` (fallback `gum`); under a WM with no
  tty → `walker` (fallback `wofi`). Override with `DOTS_MENU=walker|wofi|fzf|gum|float|plain`.
- **Markdown** (`dots view`, `dots help`): terminal → `glow | less`; WM → floating
  alacritty (`floating-md` class). Override with `DOTS_MD_VIEWER=glow|bat|less`.
- **Notifications** (`dots notify`): one wrapper, app-id `dots`, forwards
  `-i/-r/-h` so OSD progress bars (volume/brightness) work.

## Commands

| Command | Args | Summary |
|---|---|---|
| `dots theme` | list\|get\|set [name]\|cycle\|status | Switch visual theme across all surfaces |
| `dots wallpaper` | (get)\|list\|next\|prev\|random\|set <path> | Manage hyprpaper wallpaper |
| `dots style-corners` | <sharp\|round> | Sharp/round corners (Hyprland + Mako + Walker) |
| `dots volume` | raise\|lower\|mute\|mic-mute\|set <0-100>\|get\|status | PipeWire volume / mic with OSD |
| `dots brightness` | raise\|lower\|set <0-100>\|get\|status | Backlight brightness with OSD |
| `dots magnify` | in\|out\|toggle\|reset\|set <factor>\|status | Hyprland cursor zoom |
| `dots night` | toggle\|on\|off\|status | Blue-light filter (hyprsunset) |
| `dots notice` | date\|weather\|battery\|network\|system\|volume\|brightness | On-demand info notifications |
| `dots screenshot` | region [--copy]\|full\|window\|active\|delay <sec> | Capture (grim + slurp + satty) |
| `dots record` | (toggle)\|region\|stop\|status | Screen recording (wf-recorder) |
| `dots ocr` | [eng\|por\|eng+por] | OCR a region → clipboard |
| `dots color` | (pick) | Pick a color → clipboard + history |
| `dots power` | menu \| profile [cycle\|set <mode>\|list\|status] \| status | Power menu + power-profiles-daemon |
| `dots dnd` | toggle\|on\|off\|status | Do-Not-Disturb (mako) |
| `dots gamemode` | toggle\|on\|off\|status | Gaming mode (kill animations/idle) |
| `dots update` | (run)\|check\|list\|status [--json] | Cross-distro updater (pacman/apt + npm/cargo/pipx/uv/flatpak) |
| `dots hypr` | gaps\|layout\|transparency\|scale <±n\|=n>\|mirror [on\|off\|toggle]\|exit | Hyprland tweaks |
| `dots scratch` | (toggle) | Quake-style scratchpad terminal |
| `dots focus` | <pattern> [launch-cmd…] | Launch-or-focus a window |
| `dots reload` | [all\|mako\|waybar\|tmux\|ags\|fabric\|hypr\|gtk\|zsh\|bash] | Reload daemons/shells |
| `dots tui` | <command> [args…] | Open a TUI in a floating terminal |
| `dots llm` | [claude\|codex\|gemini\|aichat\|llm\|ollama] | Pick an LLM CLI in a floating terminal |
| `dots sudo` | <command> [args…] | sudo with a TUI password prompt |
| `dots setup` | <module>\|<section>/<module>\|arch-wsl\|debian-wsl\|all\|--list | Run a bootstrap module |
| `dots notify` | <title> [body] [-g/-u/-t/-a/-i/-r/-h] | Send a notification |
| `dots notifications` | restore\|dismiss\|clear\|list\|pick\|dnd | Notification history |
| `dots reminder` | <minutes> [message] \| show \| clear | Schedule a reminder |
| `dots screensaver` | (run) | terminal-text-effects screensaver |
| `dots help` | [topic \| --no-pager <topic> \| --list \| (picker)] | Cheatsheets (docs/cheatsheets/*.md) |
| `dots keybindings` | (picker) | Searchable Hyprland keybindings |
| `dots webapp` | install <name> <url> [icon]\|launch <name>\|list\|remove [name] | Firefox PWA web apps |
| `dots obsidian` | new "Title"\|today\|find\|search [Q]\|open <file> | Obsidian vault helper |
| `dots editor` | nvim native\|mini\|lazy / vim native\|plug / status | Switch nvim/vim variant (stow) |
| `dots stow` | <pkg> [--system] | Stow a package (backs up conflicts) |
| `dots hibernation` | setup\|available\|remove | Hibernation (swap = RAM) |
| `dots voxtype` | install | Install Voxtype voice dictation |

**Primitives / internal** (hidden from the picker, still callable): `dots menu`,
`dots view`, `dots notify`, `dots state`, `dots hook`, `dots gpu` (waybar JSON),
`dots askpass` (SUDO_ASKPASS target).

## Env overrides (selection)

`DOTS_MENU`, `DOTS_MD_VIEWER`, `DOTS_LIBEXEC`, `VOLUME_STEP`, `BRIGHTNESS_STEP`,
`MAGNIFY_STEP`, `WEATHER_CITY`, `NIGHT_MODE_TEMP`, `WALLPAPER_DIR`,
`SCREENSHOT_DIR`, `RECORD_DIR`, `OBSIDIAN_VAULT`, `CHEATSHEET_DIR`, `DOTFILES_DIR`.

## Add a new command

```bash
$EDITOR bin/.local/lib/dots/<group>      # case "$1" in … ; call: dots notify / dots menu / dots state
chmod +x bin/.local/lib/dots/<group>
# header metadata so the dispatcher discovers it:
#   # dots:summary=<one-line>
#   # dots:args=<usage>
#   # dots:hidden=true   (omit from the picker)
stow -R -t ~ bin                          # or: dots stow bin
```

Modules are standalone bash and **compose by calling `dots <group>`** (not by
`source`) — `dots` is always on `$PATH` and re-dispatches to `~/.local/lib/dots/`.
