# FAQ

## Why two terminals, two Neovim configs, two DEs?

Pick once, switch later. Each is a stow package — `stow -R <pkg>`
re-links, `stow -D <pkg>` removes. No commitment.

## Why omarchy as inspiration but not a clone?

omarchy is opinionated about an Arch + Hyprland + LazyVim distro
experience for users coming from Mac/Win. This repo is a hand-rolled
dotfiles set for one machine — borrows shape, not opinions. Pieces are
swappable in a way distros aren't.

## Why no NVIDIA/Intel GPU modules?

This is a single-AMD-GPU Vaio. Those modules were dead code and were
deleted. `git log -- scripts/arch/core/nvidia-gpu.sh` recovers them if
the next machine needs them.

## Why no LUKS?

The installed root isn't encrypted. The script that migrated initramfs
hooks (`core/luks.sh`) was destructive single-use code and was removed.
For new installs, pick LUKS at archinstall time.

## Why no AppArmor / usbguard?

`core/hardening.sh` shipped both but they're high-friction (kernel
cmdline edits, manual policy generation). Removed to keep the surface
small. Install on demand — instructions in [Security](03-security.md).

## How do I add a new module?

1. Write `scripts/arch/<section>/<name>.sh` — follow the pattern of any
   existing module (source `lib/common.sh`, optional `lib/detect.sh`).
2. Add to `MODULES_DESC` and `SECTION_<section>` arrays in
   [`scripts/arch/arch.sh`](../../../scripts/arch/arch.sh).
3. (Optional) add to `ALL_PRESET` if it should run in the default
   bootstrap.
4. Test: `bash -n scripts/arch/<section>/<name>.sh && ./scripts/arch/arch.sh <section>/<name>`.

## How do I add a new stow package?

1. `mkdir -p mycli/.config/mycli && cp ~/.config/mycli/config.toml $_`
2. Add `mycli` to the `packages=(…)` array in
   [`dev/stow.sh`](../../../scripts/arch/dev/stow.sh) if you want it
   auto-stowed.
3. `stow -t ~ mycli`.

## Where is the prompt configured?

`starship/.config/starship.toml` (overwritten by `dots theme set`).
See [Prompt](../configuration/03-prompt.md).

## What's in `~/.local/bin`?

Three scripts shipped via the `bin/` stow package:

- `notice` — info notifications
- `web-app` — firefoxpwa wrapper
- `hypr-scale` — monitor scale ±

## How do I survive a broken update?

```bash
sudo snapper -c root list
sudo snapper -c root rollback <id-before-update>
sudo reboot
```

See [System Snapshots](02-snapshots.md).
