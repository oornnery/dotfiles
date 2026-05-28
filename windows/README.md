# Windows side of the dotfiles

Mirrors the Linux Hyprland + AGS setup on Windows using **komorebi** (tiling WM)
+ **whkd** (keybinder) + **yasb** (status bar) + **PowerToys** (launcher / utilities),
plus an opinionated **debloat** layer.

> Layout split: install scripts live in [`scripts/win/`](../scripts/win/). This
> `windows/` directory holds only **configs/dotfiles** that the scripts link
> into place (komorebi, whkd, yasb, terminal, pwsh profile, .wslconfig,
> winscript.json, docs).

## Quick install

PowerShell 7+ as **Administrator**:

```powershell
git clone https://github.com/oornnery/dotfiles $Env:USERPROFILE\dotfiles
pwsh.exe -ExecutionPolicy Bypass -File $Env:USERPROFILE\dotfiles\scripts\win\win.ps1 all
```

Then:

```powershell
komorebic start --whkd --bar
```

For autostart, drop a shortcut to `komorebic.exe start --whkd --bar` into `shell:startup`.

## Bootstrap (`scripts/win/win.ps1`)

```powershell
.\scripts\win\win.ps1                       # interactive TUI menu (loops until 'q')
.\scripts\win\win.ps1 all                   # full bootstrap (curated preset)
.\scripts\win\win.ps1 debloat               # only debloat modules
.\scripts\win\win.ps1 core                  # all of core/
.\scripts\win\win.ps1 core/debloat-appx     # single module
```

Modules can also be invoked directly (`pwsh -File scripts/win/core/debloat-appx.ps1`).
Each module is idempotent - re-running is a no-op. Auto-elevates to admin via UAC
if not already running elevated.

## Layout

```
scripts/win/                             # INSTALL SCRIPTS (the logic)
├── win.ps1                              # TUI dispatcher (loops in interactive mode)
├── win.conf.ps1                         # THEME, ENABLE_*, GAME_LAUNCHERS, ...
├── lib/
│   ├── common.ps1                       # Log-*, Require-Admin, Stow-Junction, Set-Reg, ...
│   └── detect.ps1                       # CPU/GPU/build/edition
├── core/
│   ├── folders.ps1                      # move known folders out of OneDrive
│   ├── onedrive-disable.ps1             # kill OneDrive + block re-install
│   ├── scoop.ps1                        # scoop + buckets
│   ├── debloat-appx.ps1                 # uninstall AppX (runs in PS 5.1)
│   ├── debloat-capabilities.ps1         # DISM caps (runs in PS 5.1)
│   ├── debloat-features.ps1             # optional features (runs in PS 5.1)
│   ├── debloat-services.ps1
│   ├── debloat-tasks.ps1
│   ├── debloat-registry.ps1             # ads / Copilot / Recall / Bing / Edge
│   ├── qol-registry.ps1                 # dark mode, clipboard hist, end-task, Alt+Tab
│   ├── power.ps1                        # Ultimate Performance + MMCSS + HAGS
│   └── winscript.ps1                    # applies ../winscript.json
├── desktop/
│   ├── terminal.ps1                     # WT + Nerd Font + PSReadLine/Terminal-Icons/PSFzf
│   ├── powertoys.ps1
│   ├── wintoys.ps1                      # Wintoys + PC Manager + Windhawk
│   ├── komorebi.ps1
│   ├── whkd.ps1
│   └── yasb.ps1
├── dev/
│   ├── tools.ps1                        # fzf/eza/bat/rg/lazygit/topgrade/uv/git/gh/...
│   ├── shell.ps1                        # link pwsh profile
│   ├── editor.ps1                       # Neovim (copia nvim-lazy) + VSCode
│   ├── llms.ps1                         # Claude Code + Codex (+ Ollama optional)
│   └── wsl.ps1
├── game/
│   ├── stack.ps1                        # launchers (Steam + Epic + EA + LoL + Minecraft + ...)
│   ├── controllers.ps1                  # PS4/PS5: ViGEmBus + HidHide + DS4Windows
│   └── bluestacks.ps1                   # Android emulator (opt-in)
├── pkgs/                                # script data (not dotfiles)
│   ├── remove.txt                       # AppX patterns to uninstall
│   ├── keep.txt                         # whitelist (overrides remove.txt)
│   ├── install.txt                      # winget IDs grouped by purpose
│   ├── core.ubundle                     # UniGetUI bundle: base utilities
│   ├── desktop.ubundle                  # UniGetUI bundle: terminal + shell
│   ├── dev.ubundle                      # UniGetUI bundle: coding stack
│   ├── work.ubundle                     # UniGetUI bundle: browsers + productivity + media
│   ├── game.ubundle                     # UniGetUI bundle: launchers + controllers
│   └── llms.ubundle                     # UniGetUI bundle: AI clis
├── winscript.json                       # flick9000/WinScript config (applied by core/winscript)
└── pkgs.ubundle                         # master UniGetUI bundle (everything in one file)

windows/                                 # DOTFILES ONLY (configs linked into place)
├── komorebi/                            # komorebi.json + helper scripts (called by keybinds)
├── whkd/whkdrc
├── yasb/                                # config.yaml + styles.css
├── terminal/settings.json               # Catppuccin Mocha + JetBrainsMono NF
├── Powershell/Microsoft.PowerShell_profile.ps1   # mirrors .zshrc
├── docs/cheatsheet.md
└── .wslconfig
```

## Module template

```powershell
#Requires -Version 7
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot\..\lib\common.ps1"
Require-Admin
Log-Banner 'section' 'module-name'

Winget-Install 'Some.Package'
Scoop-Install @('bat','eza')
Set-Reg 'HKCU:\Software\...' 'Name' 1
Stow-Junction "$dotfiles\windows\foo" "$Env:USERPROFILE\.config\foo"

Log-Ok 'module done'
```

## Package managers: winget vs scoop

Two coexist on purpose. Rule of thumb:

| Use **winget** for                                       | Use **scoop** for                            |
| -------------------------------------------------------- | -------------------------------------------- |
| Microsoft / Store apps (Terminal, PowerToys, PowerShell) | CLI / dev tools (bat, eza, fzf, rg, ...)     |
| GUI desktop apps (browsers, editors, launchers)          | Nerd fonts (winget has no font category)     |
| Game launchers (Steam, Epic, EA)                         | komorebi / whkd / yasb (bucket-distributed)  |
| Anything that needs "Add/Remove Programs" entry          | Build deps (gcc, make, tree-sitter)          |
| Anything that needs machine-wide install                 | Anything you call from scripts (shim PATH)   |

**One-command update for both** via [topgrade](https://github.com/topgrade-rs/topgrade)
(installed by `scripts/win/dev/tools.ps1`):

```powershell
update          # function in the pwsh profile -> topgrade --yes
                # winget + scoop + npm globals + pwsh modules + WSL distros
                # + git repos in PATH + rust toolchain + ... in one pass
```

GUI equivalent: **UniGetUI** (in `pkgs/install.txt`).

## Conventions

| Linux                | Windows                       |
| -------------------- | ----------------------------- |
| `M` (Super)          | `Alt`                         |
| `MS` (Super+Shift)   | `Alt+Shift`                   |
| `MC` (Super+Ctrl)    | `Alt+Ctrl`                    |
| `MCA`                | `Ctrl+Alt+Shift`              |
| Hyprland             | komorebi                      |
| AGS bar              | yasb                          |
| walker               | PowerToys Run (`Alt+R` / `Alt+Space`) |
| mako                 | Action Center (`Win+A`)       |
| alacritty            | Windows Terminal              |
| grim+slurp+satty     | ShareX / `Win+Shift+S`        |
| cliphist             | Windows clipboard (`Win+V`)   |
| emoji walker         | Windows emoji panel (`Win+.`) |

## Debloat: what it removes vs keeps

- **Removed:** DevHome, YourPhone, Widgets shell, CrossDevice, Clipchamp,
  Xbox app + Xbox TCUI + XboxSpeechToText (kept: IdentityProvider +
  GamingOverlay for FPS overlay), StickyNotes/Alarms/SoundRecorder,
  Bing*, Outlook (PWA), PowerAutomate, Todos, Feedback Hub, QuickAssist,
  OfficeHub, SolitaireCollection, OneDrive, Teams, Skype, Maps, People,
  3DBuilder, MixedReality.
- **Kept:** Photos, Camera, ZuneMusic (= the new Media Player),
  Calculator, Notepad, Paint, SnippingTool, Store, Terminal,
  WindowsSecurity, codec extensions.
- **Capabilities removed:** WordPad, IE, legacy WMP, XPS Viewer, Fax/Scan,
  MathRecognizer, StepsRecorder, PowerShell ISE.
- **QoL enabled:** dark mode, clipboard history (Win+V), end-task in
  taskbar, long paths, show extensions/hidden files, This-PC as Explorer
  home, mouse accel off, **Alt+Tab without browser tabs**,
  Ultimate Performance power plan, HAGS, MMCSS gaming tweaks.

Edit `scripts/win/pkgs/remove.txt` and `scripts/win/pkgs/keep.txt` to tune.

## PowerToys utilities used

| Feature                 | Bound to            | Linux analog                |
| ----------------------- | ------------------- | --------------------------- |
| PowerToys Run           | `Alt+R` / `Alt+Space` | walker default search     |
| ColorPicker             | `Alt+Shift+C` / `Win+Shift+C` | color-picker script |
| Text Extractor (OCR)    | `Win+Shift+T`       | ocr script                  |
| Awake                   | tray                | hypridle inhibit            |
| FancyZones              | `Win+\``            | hyprland window layouts     |
| Keyboard Manager        | (Settings)          | hyprland kb_options         |
| Always On Top           | `Win+Ctrl+T`        | hyprland pin/float-on-top   |

## See also

- [windows/docs/cheatsheet.md](docs/cheatsheet.md) - full keybind reference.
- [docs/cheatsheets/](../docs/cheatsheets/) - cross-platform cheatsheets.
