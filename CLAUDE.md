# CLAUDE.md

Repo brief for future Claude sessions. Read this first.

## What this is

Personal dotfiles + post-archinstall bootstrap, single-user, tuned for
**one specific machine**:

- VAIO laptop (Positivo Bahia VAIO)
- AMD CPU + AMD GPU (no NVIDIA / Intel iGPU)
- btrfs root (no LUKS today)
- GNOME (default DE) + Hyprland (target Wayland WM)
- GDM as login manager, greetd as backup

Anything that doesn't fit that hardware is either skipped by detection
or has been deleted from the tree (e.g. nvidia-gpu.sh, luks.sh).

## Layout

```
~/dotfiles/
├── CLAUDE.md                this file
├── README.md                user-facing readme
├── docs/                    user manual + tool cheatsheets
│   ├── README.md
│   ├── basics/         (7)  welcome, getting-started, navigation, hotkeys, …
│   ├── applications/   (9)  terminal, neovim, shell-tools, tuis, …, bin-scripts
│   ├── configuration/  (8)  monitors, prompt, theming, system-stow, …
│   ├── rest/           (4)  troubleshooting, snapshots, security, faq
│   └── cheatsheets/   (18)  zsh, bash, tmux, fzf, eza, bat, git, …
│
├── scripts/
│   ├── arch.sh              alias for backwards compat (deleted? check)
│   ├── arch/                THE bootstrap — see below
│   ├── debian.sh            flat one-shot script for Debian / WSL
│   ├── zsh.sh, stow.sh      legacy entry points
│   └── rich-log.sh          old log library (kept for reference)
│
├── <stow packages at root>  → linked to $HOME or /
│   ├── zsh/ bash/ tmux/ vim/ alacritty/      shell + terminal
│   ├── nvim/ nvim-lazy/                      editor distros (mutex)
│   ├── hyprland/ waybar/ wofi/ mako/         Wayland WM stack
│   ├── bin/                                  ~/.local/bin/ helpers (24 scripts)
│   ├── git/ editor/ fabric/ vscode/          dev workflow
│   ├── greetd/ gdm/ iwd/ wsl/ zram/          /etc/ configs via stow_system
│   └── themes/                               catppuccin-mocha, tokyo-night, latte
│
└── .gitignore               arch.log, .claude/
```

## scripts/arch — the bootstrap

```
scripts/arch/
├── arch.sh                  interactive TUI launcher
├── arch.conf                env-var overrides (uncommented = active)
├── lib/
│   ├── common.sh            log::*, ask::*, snapshot, stow_safe, stow_system
│   ├── detect.sh            detect::system → CPU/GPU/laptop/VM/WSL vars
│   └── bootloader.sh        append_kernel_param (systemd-boot + GRUB)
├── core/                    base, hw, security, package infra
├── desktop/                 display managers + DEs
├── dev/                     tools, shell, editor, language, container, AI
└── game/                    gaming stack
```

Run modes:

```bash
./scripts/arch/arch.sh                  # TUI menu
./scripts/arch/arch.sh all              # curated "all" preset
./scripts/arch/arch.sh <section>        # all of core/desktop/dev/game
./scripts/arch/arch.sh <section>/<mod>  # one module
./scripts/arch/dev/zsh.sh               # standalone — same effect
```

Modules can also be invoked directly. They self-check root (`require_root`)
and pick up `USER_NAME` from `$SUDO_USER` or `$USER`.

## Module conventions (all scripts/arch/*/*.sh)

```bash
#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../lib/detect.sh"   # if needed

require_root
detect::system                # populates $IS_WSL $IS_VM $CPU_VENDOR …

log::banner "Section" "Module name"

# guard against unsupported environments
[[ $IS_WSL -eq 1 ]] && { log::skip "WSL: skipped"; exit 0; }

log::info "Installing X"
sudo pacman -S --needed --noconfirm pkg1 pkg2

# Stow user config (auto-backs up real-file conflicts)
stow_safe pkgname

# Stow /etc config (root, with backup)
stow_system pkgname

# Enable service (no helper — direct systemctl)
sudo systemctl enable --now foo.service

log::ok "Module setup completed"
```

Style rules:
- `sudo pacman -S --needed --noconfirm` (no `pkg::install` helper)
- `sudo systemctl enable …` (no wrapper)
- `command -v X` is fine within the script; **NOT** `sudo -u USER command -v X`
  (`command` is a shell builtin; use `sudo -u USER bash -c 'command -v X'`)
- All modules idempotent — re-running is a no-op
- Run-as-root vs run-as-user: scripts that need sudo run with sudo; for
  stow steps, helpers auto-drop privilege to `$SUDO_USER` when called
  from a root context
- shellcheck `Info: Not following …` is harmless (external sources)

## Detection vars (from `detect::system`)

| Var              | Values                                       |
| ---------------- | -------------------------------------------- |
| `$IS_WSL`        | 0 / 1                                        |
| `$IS_VM`         | 0 / 1                                        |
| `$VM_TYPE`       | qemu, oracle, vmware, microsoft, none        |
| `$IS_LAPTOP`     | 0 / 1                                        |
| `$CHASSIS_TYPE`  | DMI chassis number                           |
| `$CPU_VENDOR`    | intel / amd / unknown                        |
| `$GPU_VENDORS`   | bash array of: amd, intel, nvidia            |
| `$DMI_VENDOR`    | mfg string (used for VAIO, Dell, etc quirks) |
| `$ROOT_FS`       | btrfs, ext4, xfs, …                          |
| `$HAS_LUKS`      | 0 / 1                                        |
| `$HAS_BLUETOOTH` | 0 / 1                                        |
| `$CURRENT_DM`    | gdm / greetd / sddm / ly / none              |
| `$CURRENT_KERNEL`| `uname -r`                                   |

## arch.conf — what each var does

```bash
USER_NAME           defaults to $SUDO_USER or $USER
USER_SHELL          login shell to chsh into (default /bin/zsh)
HOSTNAME_NEW        not currently used by modules (placeholder)
DOTFILES_DIR        repo path; default $HOME/dotfiles
LOCALE, TIMEZONE, KEYMAP, XKB_*    locale module
MIRROR_COUNTRY      reflector
EXTRAS              pipewire pro-audio packages (0/1)
USE_IWD             NM backend (1 default — iwd + impala)
POWER_BACKEND       ppd | tlp | auto-cpufreq
DESKTOPS=()         array: which desktop/<x> modules go into ALL_PRESET
DISPLAY_MANAGER     gdm | greetd | sddm | ly
DM_SESSION_CMD      session greetd boots into (default Hyprland)
ENABLE_FINGERPRINT  fprintd setup (opt-in)
WEATHER_CITY        `notice weather` city
NVIM_DISTRO         mini | lazy — which nvim/ stow gets linked
THEME               catppuccin-mocha (default) | tokyo-night | catppuccin-latte
AUR_PKGS=()         array passed to paru after bootstrap
ENABLE_CLAUDE_CODE, ENABLE_CODEX, ENABLE_OLLAMA,
ENABLE_LM_STUDIO, ENABLE_RTK, ENABLE_AGENTS, AGENTS_REPO    dev/llms.sh
```

## Stow workflow

User-side: `stow_safe <pkg>` symlinks `~/dotfiles/<pkg>/...` → `$HOME/...`.
System-side: `stow_system <pkg>` does `sudo stow -t / -R <pkg>`. Both
back up real-file conflicts to `*.bak.<timestamp>` first.

Stow packages auto-stowed by `dev/stow.sh`:

```
bash zsh tmux vim git editor fabric alacritty bin waybar wofi mako
+ nvim or nvim-lazy   (per NVIM_DISTRO)
+ wsl                 (if IS_WSL)
```

System stow packages (via individual modules):
`greetd/`, `gdm/`, `iwd/` (when USE_IWD=1), `wsl/`, `zram/`.

For boundaries on what's safe to stow into `/etc/`, see
[docs/configuration/08-system-stow.md](docs/configuration/08-system-stow.md).

## bin/ scripts (24 total)

Live at `~/.local/bin/` after stowing `bin/`. Catalog in
[docs/applications/09-bin-scripts.md](docs/applications/09-bin-scripts.md).

Notable:
- `theme` — switch alacritty/waybar/wofi/mako/starship palette
- `notice` — date/weather/battery/network/system notifications
- `screenshot`, `record`, `ocr`, `color-picker`
- `volume`, `brightness`, `magnify` — replace swayosd-client
- `power-profile`, `power-menu`, `dnd`, `night-mode`, `update`
- `floating-tui` — wrapper for `alacritty --class floating -e <tui>`
- `web-app` — firefoxpwa launcher
- `clipboard`, `wallpaper`, `emoji`, `unicode`, `window-finder`, `scratch`

## Theming

5 surfaces themed: alacritty, waybar, wofi, mako, starship.
3 themes: `catppuccin-mocha` (default), `tokyo-night`, `catppuccin-latte`.

Switch:

```bash
theme list
theme set tokyo-night
theme cycle              # Hyprland: Super + Ctrl + Alt + Y
```

Files in `themes/<name>/` are copied to `~/.config/<app>/theme.*`,
which the live config files import. Adding a theme = `cp -r` an
existing one, edit colors, `theme set` it. See
[docs/configuration/07-theming.md](docs/configuration/07-theming.md).

## Common tasks

### Add a new module

```bash
# 1. Write scripts/arch/<section>/<name>.sh following the module template above
# 2. Register in scripts/arch/arch.sh:
#      MODULES_DESC[<section>/<name>]="description"
#      SECTION_<section>+=( <name> )
# 3. (Optional) add to ALL_PRESET if it should run in the curated bootstrap
# 4. Test: bash -n scripts/arch/<section>/<name>.sh
```

### Add a new $HOME stow package

```bash
mkdir mypkg/.config/myapp
cp ~/.config/myapp/config.toml mypkg/.config/myapp/config.toml
# Add `mypkg` to packages=() in scripts/arch/dev/stow.sh (optional)
stow_safe mypkg   # idempotent re-stow with backup
```

### Add a new /etc stow package

```bash
mkdir -p mypkg/etc/mything
cp /etc/mything/config.conf mypkg/etc/mything/config.conf
# Write scripts/arch/core/mything.sh that calls `stow_system mypkg`
```

Only safe for late-boot configs. See system-stow doc for the
hard-blockers (fstab, sudoers, mkinitcpio.conf, bootloader, etc.).

### Add a bin/ script

```bash
$EDITOR bin/.local/bin/foo
chmod +x bin/.local/bin/foo
stow -R -t ~ bin
$EDITOR docs/applications/09-bin-scripts.md   # add to catalog
```

## Things to never do

- Don't add `pkg::install` / `service::enable` helpers — direct
  pacman/systemctl is the convention. Earlier attempts were removed.
- Don't stow into `/etc/fstab`, `/etc/sudoers*`, `/etc/mkinitcpio.conf`,
  bootloader paths, or `/etc/passwd*`. Read system-stow doc.
- Don't replace `bin/` scripts with library-based ones — they're
  standalone on purpose (POSIX-friendly, no `source common.sh`).
- Don't blow away `scripts/templates/` — it's gone, configs live at root.
- Don't add nvidia-gpu / intel-gpu / luks modules — deleted on purpose
  for this hardware. `git log` recovers them if a new machine needs them.

## Commit conventions

```
<type>(<scope>): <short subject>

<body explaining what + why, not how>

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
```

Types in use: `feat`, `chore`, `refactor`, `docs`, `fix`. Recent log:

```
ddb8729 docs: explain system-stow approach
0bd44e3 feat(core): zram back as stow package (size = ram, zstd)
57e8593 feat: move iwd + wsl configs to root stow packages
5f13c1d feat(desktop): greetd + gdm configs become stow packages
68d07e8 chore: drop zram support (then re-added — see 0bd44e3)
795dca6 feat(arch/dev): vscodium module
14aa14c chore(debian): expand to match Arch setup
57e8593 etc.
```

## When the user asks me to…

- **"add a new tool X"** → think: is it pacman / AUR / curl?
  Add to `dev/tools.sh` (general CLI) or new `dev/X.sh` (deserves a
  module) or `core/X.sh` (system-level).
- **"new bin script"** → write at `bin/.local/bin/<name>`, chmod +x,
  add to `09-bin-scripts.md` catalog.
- **"change theme"** → edit `themes/<name>/<app>` files or create
  new theme dir.
- **"bind X to Y"** → edit `hyprland/.config/hypr/bindings.conf`.
- **"update arch.conf"** → keep the "default uncommented, alternatives
  commented below" pattern.
- **commit/push** → only if explicitly asked (per user prefs).

## Quick verification

```bash
# After making changes
bash -n $(find scripts/arch -name '*.sh' -o -name '*.bash')   # syntax
bash -n bin/.local/bin/*                                      # bin
./scripts/arch/arch.sh --help                                 # menu sanity
source scripts/arch/lib/common.sh; source scripts/arch/lib/detect.sh
detect::system                                                # detection
```
