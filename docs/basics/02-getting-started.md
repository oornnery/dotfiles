# Getting Started

From a fresh Arch install (post-archinstall, you're logged in as root or
your user with sudo) to a working desktop.

## 0. Clone

```bash
sudo pacman -S --needed git
git clone https://github.com/oornnery/dotfiles ~/dotfiles
cd ~/dotfiles
```

## 1. Tune the config

```bash
$EDITOR scripts/arch/arch.conf
```

Defaults are uncommented; alternatives are commented below each. Mind:

- `USER_NAME` — auto-resolves to `$USER`; override if needed
- `TIMEZONE`, `LOCALE`, `MIRROR_COUNTRY`
- `POWER_BACKEND="ppd"` — `tlp` or `auto-cpufreq` are alternatives
- `ENABLE_FINGERPRINT=0` — set to `1` if you have a fingerprint reader

## 2. Run the launcher

```bash
./scripts/arch/arch.sh
```

You'll get a TUI menu:

```
What to run?
  ❯ Run 'all' preset (recommended initial setup)
    core     — base, hw, security, AUR infra
    desktop  — gdm, greetd, sddm, ly, gnome, hyprland
    dev      — tools, zsh, stow, languages, docker, llms
    game     — gaming
    Quit
```

Pick **'all' preset** for a sensible bootstrap (covers everything except
opt-in modules like `core/fingerprint`, `core/windows-vm`, `game/`).

## 3. Reboot

After the preset completes, reboot. Microcode and kernel-param changes
take effect on next boot.

## 4. Log into Hyprland

GDM lets you pick the session from the gear icon. Pick Hyprland.

On first launch:

- The autostart fires: waybar, mako, hypridle, udiskie, polkit, nm-applet
- Stowed configs (`~/.config/hypr/`, `~/.config/alacritty/`, `~/.tmux.conf`,
  `~/.zshrc`) are already in place
- `~/.local/bin/{notice,web-app,hypr-scale}` are on `$PATH` after relogin

## 5. Optional next steps

```bash
./scripts/arch/arch.sh core/fingerprint   # if you set ENABLE_FINGERPRINT=1
./scripts/arch/arch.sh core/firefoxpwa    # then install the extension and add PWAs
./scripts/arch/arch.sh core/windows-vm    # writes the docker-compose
./scripts/arch/arch.sh game/gaming        # Steam + wine
```

Re-run individual modules anytime; they're idempotent (skip what's
already done).

## See also

- [CLI Bootstrap](07-cli.md) — `arch.sh` flags, presets, sections
- [Dotfiles (Stow)](../configuration/05-dotfiles.md) — adding new packages
