# System Snapshots

[snapper](http://snapper.io/) + [snap-pac](https://github.com/wesbarnett/snap-pac)
take btrfs snapshots automatically:

- Before & after every `pacman -S/U/R/Sy` (snap-pac hook)
- Hourly / daily / weekly per timer (snapper-timeline)

Set up by [`core/snapper.sh`](../../../scripts/arch/core/snapper.sh)
when `ROOT_FS == btrfs`.

## Usage

```bash
sudo snapper -c root list                     # show all snapshots
sudo snapper -c root create -d "before X"     # manual snapshot
sudo snapper -c root delete N                 # delete by id
sudo snapper -c root status N..M              # diff between two snapshots
sudo snapper -c root undochange N..M FILE     # roll one file back
```

## Restore a whole snapshot

If a `pacman -Syu` broke userspace:

```bash
sudo snapper -c root list                     # find the "pre" snapshot id
sudo snapper -c root rollback <id>            # creates a new snapshot from that one
sudo reboot
```

The rollback creates a **new** snapshot — original history is preserved.

## Boot-time rollback (btrfs-snap entries)

Not configured by default. To enable, install `snap-pac-grub` or
`grub-btrfs` and let it auto-generate boot entries for each snapshot.
You can then pick a known-good snapshot from GRUB if userspace won't
come up at all.

## Disk usage

Snapshots are CoW — they cost only the diff. Check actual usage:

```bash
sudo btrfs filesystem usage /
sudo compsize -x /                            # compression ratio per subvol
```

If `/` fills up, delete old snapshots first:

```bash
sudo snapper -c root list | head -20         # see oldest entries
sudo snapper -c root delete 1-50             # delete a range
```

## Config

`/etc/snapper/configs/root` — limits how many snapshots are kept:

```ini
TIMELINE_LIMIT_HOURLY="10"
TIMELINE_LIMIT_DAILY="10"
TIMELINE_LIMIT_WEEKLY="0"
TIMELINE_LIMIT_MONTHLY="0"
TIMELINE_LIMIT_YEARLY="0"
NUMBER_LIMIT="50"
```

Adjust to taste. After editing, snapper-cleanup runs periodically and
trims to the new limits.
