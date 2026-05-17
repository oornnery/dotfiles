# Gaming

[`game/gaming.sh`](../../../scripts/arch/game/gaming.sh) installs the
Steam + wine + gamemode stack. Requires `[multilib]` enabled in
`pacman.conf` — `core/pacman.sh` does that automatically.

## What's installed

| Package         | Purpose                                                  |
| --------------- | -------------------------------------------------------- |
| steam           | Valve client + Proton                                    |
| lutris          | Game launcher for non-Steam stores                       |
| heroic-games-launcher-bin (AUR) | Epic / GOG / Amazon launcher             |
| wine, wine-mono, wine-gecko, winetricks | Windows compat baseline            |
| gamemode, lib32-gamemode | runtime CPU governor tuning while a game runs   |
| mangohud, lib32-mangohud | FPS + frametime overlay (toggle with `F12`)     |
| sc-controller   | DS4 / Steam Controller / generic gamepad mapper          |
| xboxdrv         | Xbox controller userspace driver                         |

## Run

```bash
./scripts/arch/arch.sh game/gaming
```

Or pick `game/gaming` from the menu (under "game" section).

## After install

1. Open Steam → log in → **Steam → Settings → Compatibility → Enable
   Steam Play for all titles** (Proton)
2. Per-game tuning: right-click game → **Properties → Launch Options**:
   ```text
   gamemoderun mangohud %command%
   ```
3. AMD GPU on Wayland: most modern Vulkan titles work out of the box;
   problematic titles can be forced to OpenGL via Proton tinkering.

## Controllers

- **sc-controller** ships a daemon + GTK GUI that maps any joystick
  (DS4, generic) to a virtual Xbox controller, which most Linux games
  understand:
  ```bash
  sc-controller-daemon            # start daemon (auto-detects connected gamepad)
  sc-controller                   # GUI to remap buttons/axes per game
  ```
- Connect DS4 via USB or Bluetooth (bluez pairs it; `bluetuectl trust <MAC>`
  to keep it connected across reboots).
- After install, you may need to re-login for `input`/`uucp` group
  membership to apply.

## Tools beyond the script

- **Bottles** (Flatpak — wine prefix manager): `flatpak install flathub com.usebottles.bottles`
- **Moonlight** (AUR — GeForce streaming): `paru -S moonlight-qt`
- **GameHub** (Flatpak — multi-launcher with native + emulators)
- **RetroArch** (`pacman -S retroarch`)

None auto-installed — `game/gaming.sh` keeps to the basics.

## Diagnostics

```bash
gamemoded -t        # test gamemoded is functional
mangohud glxgears   # check overlay
vulkaninfo --summary  # validate AMD GPU stack
radeontop           # live GPU usage
```
