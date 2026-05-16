# Common Tweaks

Small adjustments that don't fit a dedicated module.

## Power: switch backend

[`core/power.sh`](../../../scripts/arch/core/power.sh) supports three:

```bash
# arch.conf
POWER_BACKEND="ppd"           # default — power-profiles-daemon
# POWER_BACKEND="tlp"
# POWER_BACKEND="auto-cpufreq"
```

Switching requires re-running the module — it masks the previous one's
systemd unit.

## Sleep: AMD kernel params

Already applied by `core/notebook-vaio.sh` and `core/power.sh` for AMD:

```text
amd_pstate=active mem_sleep_default=s2idle
```

If sleep is flaky, drop `mem_sleep_default=s2idle` and try deep sleep:

```bash
echo deep | sudo tee /sys/power/mem_sleep
```

To make it permanent, edit the bootloader entry (systemd-boot in
`/boot/loader/entries/*.conf`) and remove the param.

## Snapper

[`core/snapper.sh`](../../../scripts/arch/core/snapper.sh) sets up:

- `snapper -c root` config on `/`
- `snap-pac` hook → snapshot before/after every `pacman -S/U/R/Sy`

See [System Snapshots](../rest/02-snapshots.md) for usage.

## Pacman

[`core/pacman.sh`](../../../scripts/arch/core/pacman.sh) enables:

- `ParallelDownloads = 10`
- `Color` + `ILoveCandy`
- `VerbosePkgLists`
- `CheckSpace`
- `[multilib]` (x86_64 only)

Add `[chaotic-aur]` manually if you decide you want it — that script
was removed to keep the surface small.

## Locale

[`core/locale.sh`](../../../scripts/arch/core/locale.sh) enables both
`en_US.UTF-8` and `pt_BR.UTF-8`. Switch the system default by changing
`LOCALE=` in `arch.conf` and rerunning the module.
