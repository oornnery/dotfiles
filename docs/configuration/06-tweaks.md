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

## Zram

Compressed swap in RAM. Useful when running multiple VMs or CPU-offloaded
LLM inference — workloads that pin a lot of RAM. With zstd compression
(~3:1), a 32 GB zram device can hold ~96 GB of cold pages before the
kernel actually runs out of room.

Config (stow-managed):
[`zram/etc/systemd/zram-generator.conf`](../../zram/etc/systemd/zram-generator.conf)

```ini
[zram0]
zram-size = ram               # use 100% of total RAM
compression-algorithm = zstd
swap-priority = 100
fs-type = swap
```

`core/zram.sh` runs `stow_system zram` to link this file to
`/etc/systemd/zram-generator.conf`, then activates it without a reboot:

```bash
sudo systemctl restart systemd-zram-setup@zram0.service
zramctl                                  # confirm /dev/zram0 is up
swapon --show                            # zram listed with priority 100
```

To dial it back (reserve more uncompressed RAM for active processes):
edit `zram/etc/systemd/zram-generator.conf` → change `zram-size = ram` to
`ram / 2` → re-run the restart command.

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
