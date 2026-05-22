# Windows side of the dotfiles

Mirrors the Linux Hyprland + AGS setup on Windows using **komorebi** (tiling WM)
+ **whkd** (keybinder) + **yasb** (status bar) + **PowerToys** (launcher / utilities).

## Quick install

PowerShell 7+ as **Administrator**:

```powershell
git clone https://github.com/oornnery/dotfiles $Env:USERPROFILE\dotfiles
pwsh.exe -ExecutionPolicy Bypass -File $Env:USERPROFILE\dotfiles\windows\scripts\bootstrap.ps1
pwsh.exe -ExecutionPolicy Bypass -File $Env:USERPROFILE\dotfiles\windows\scripts\desktop.ps1
```

Then:

```powershell
komorebic start --whkd --bar
```

For autostart, drop a shortcut to `komorebic.exe start --whkd --bar` into
`shell:startup`.

## Layout

```
windows/
├── .wslconfig                       — WSL2 memory/cpu config
├── pkgs.ubundle                     — UniGetUI export (full app list)
├── winscript.json                   — flick9000/WinScript debloat config
├── komorebi/
│   ├── komorebi.json                — WM config (monitors, padding, rules)
│   ├── applications.yaml            — per-app float/ignore
│   ├── power-menu.ps1               — Alt+Shift+P (lock/sleep/restart/shutdown w/ confirm)
│   ├── scratchpad.ps1               — Alt+` (quake-toggle Terminal)
│   └── cheatsheet.ps1               — Alt+Shift+H (fzf+glow picker)
├── whkd/whkdrc                      — keybindings (mirrors hyprland/.../bindings.lua)
├── yasb/
│   ├── config.yaml                  — bar layout (matches AGS Bar.tsx 1:1)
│   └── styles.css                   — palette + per-module colors + hover
├── PowerShell/
│   └── Microsoft.PowerShell_profile.ps1  — pwsh profile (mirrors .zshrc)
├── scripts/
│   ├── bootstrap.ps1                — first-run: core tools + folders + profile
│   └── desktop.ps1                  — komorebi/whkd/yasb/PowerToys install
└── docs/cheatsheet.md               — full keybind reference + tips
```

## Conventions

| Linux                | Windows                       |
| -------------------- | ----------------------------- |
| `M` (Super)          | `Alt`                         |
| `MS` (Super+Shift)   | `Alt+Shift`                   |
| `MC` (Super+Ctrl)    | `Alt+Ctrl`                    |
| `MCA`                | `Ctrl+Alt+Shift`              |
| Hyprland             | komorebi                      |
| AGS bar              | yasb                          |
| walker               | PowerToys Run (`Alt+R` or `Alt+Space`) |
| mako                 | Action Center (`Win+A`)       |
| alacritty            | Windows Terminal              |
| grim+slurp+satty     | ShareX / Win+Shift+S          |
| cliphist             | Windows clipboard (`Win+V`)   |
| emoji walker         | Windows emoji panel (`Win+.`) |

## PowerToys utilities used

| PowerToys feature       | Bound to            | Linux analog                |
| ----------------------- | ------------------- | --------------------------- |
| PowerToys Run           | `Alt+R` / `Alt+Space` | walker default search     |
| ColorPicker             | `Alt+Shift+C` / `Win+Shift+C` | color-picker script |
| Text Extractor (OCR)    | `Win+Shift+T`       | ocr script                  |
| Awake                   | tray                | hypridle inhibit            |
| FancyZones              | `Win+\``            | hyprland window layouts     |
| Keyboard Manager        | (Settings)          | hyprland kb_options         |
| Always On Top           | `Win+Ctrl+T`        | hyprland pin/float-on-top   |

## See also

- [windows/docs/cheatsheet.md](docs/cheatsheet.md) — full keybind reference.
- [docs/cheatsheets/](../docs/cheatsheets/) — cross-platform cheatsheets (zsh,
  nvim, git, tmux, …) opened via the `dots-cheatsheet` script on Linux or
  `cheatsheet.ps1` on Windows.
