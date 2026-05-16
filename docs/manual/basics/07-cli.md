# CLI Bootstrap

[`scripts/arch/arch.sh`](../../../scripts/arch/arch.sh) is the only entry
point. It reads [`arch.conf`](../../../scripts/arch/arch.conf), sources
[`lib/common.sh`](../../../scripts/arch/lib/common.sh) (logging + prompts)
and [`lib/detect.sh`](../../../scripts/arch/lib/detect.sh) (hardware
detection), then either drops you into a menu or runs a section/module.

## Usage

```bash
./arch.sh                  # interactive menu (↑/↓ + space + enter)
./arch.sh all              # curated "all" preset for fresh-install
./arch.sh core             # run every module in core/
./arch.sh core/zsh         # one module
./arch.sh --help
```

## Layout

```
scripts/arch/
├── arch.sh              # launcher
├── arch.conf            # env overrides (defaults uncommented)
├── lib/
│   ├── common.sh        # log::*, ask::*, snapshot, require_root, die
│   ├── detect.sh        # CPU/GPU/laptop/VM/WSL/btrfs/LUKS detection
│   └── bootloader.sh    # kernel-cmdline patcher (systemd-boot + GRUB)
├── core/                # base, hw, security, package infra
├── desktop/             # display managers + DEs
├── dev/                 # tools, zsh, stow, languages, docker, llms
└── game/                # gaming
```

## ALL_PRESET

The order matters. Defined in `arch.sh`:

1. `core/preflight` — checks + mirrorlist
2. `core/pacman` — pacman.conf tuning + multilib
3. `core/base-utils` — base packages + microcode + fonts
4. `core/locale`
5. `core/user`
6. `core/core-services`
7. `core/keyring`
8. `core/networkmanager`
9. `core/bluetooth`
10. `core/pipewire`
11. `core/storage` — udisks2 + udiskie
12. `core/monitoring` — sensors + smartctl
13. `core/amd-gpu`
14. `core/notebook-vaio` — vendor tuning + iio-sensor-proxy
15. `core/power`
16. `core/zram`
17. `core/snapper`
18. `desktop/hyprland`
19. `dev/zsh`
20. `dev/stow`
21. `dev/tools`
22. `dev/languages`
23. `dev/docker`
24. `core/paru`
25. `core/ufw`

Opt-in (not in `all`): `core/fingerprint`, `core/windows-vm`,
`core/firefoxpwa`, `core/vm-guest`, `core/flatpak`, `core/wsl`,
`dev/llms`, `game/gaming`, and any of the alternate display managers.

## Logging

Everything writes to `scripts/arch/lib/arch.log` (gitignored). Tail it
in another pane while running:

```bash
tail -f scripts/arch/lib/arch.log
```

Colours/badges come from `lib/common.sh`. Set `NO_COLOR=1` to disable.
