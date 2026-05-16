# Shell Functions

Custom shell helpers live in [`zsh/.zsh_functions`](../../../zsh/.zsh_functions),
sourced by `.zshrc`. They're plain bash-compatible functions — `type
compress` in a shell shows you the source.

## Archive helpers

| Function                  | What it does                                       |
| ------------------------- | -------------------------------------------------- |
| `compress <path…>`        | Tar + multi-threaded zstd → `<path>.tar.zst`       |
| `decompress <archive>`    | Auto-detects format (zst/gz/xz/bz2/zip/7z/rar)     |

```bash
compress ~/projects/foo            # → foo.tar.zst
decompress release-1.2.3.tar.gz    # → in-place
```

## Disk helpers (destructive)

Both require typing the device path to confirm — no `--force` flag, no
typo wipes.

| Function                       | What it does                                  |
| ------------------------------ | --------------------------------------------- |
| `iso2sd <iso> <device>`        | `dd if=iso of=device bs=4M status=progress`   |
| `format-drive <device> [fs]`   | `mkfs.<fs>` (defaults to ext4)                |

Supported `fs` types: `ext4` (default), `btrfs`, `xfs`, `exfat`, `ntfs`,
`vfat`/`fat32`.

```bash
iso2sd ~/Downloads/archlinux.iso /dev/sdb
# ABOUT TO WIPE: /dev/sdb
# (lsblk preview)
# Type the device path to confirm: /dev/sdb
# … dd progress …
```

## Network helpers (no args)

| Function | Output                                              |
| -------- | --------------------------------------------------- |
| `fip`    | LAN IPv4 of each non-virtual interface              |
| `dip`    | Default route gateway IP                            |
| `lip`    | IPv6 link-local addresses per interface             |

```bash
$ fip
wlan0 192.168.0.123
$ dip
192.168.0.1
```

## SSH port forwarding

| Function                                | What it does                                       |
| --------------------------------------- | -------------------------------------------------- |
| `rfwd <local-port> <remote-host> [rp]`  | `ssh -R rp:localhost:lp host` (remote forward)     |

Use case: expose a local dev server through a public box for webhook
testing.

```bash
rfwd 3000 my-vps.example.com 80
# remote my-vps.example.com:80 → localhost:3000
```

## Adding your own

Edit `~/dotfiles/zsh/.zsh_functions`, save, then `reload` (alias for
`exec zsh`). Functions get picked up automatically because `.zshrc`
sources the file at startup.

```bash
# zsh/.zsh_functions
weather() {
    curl -fsSL "wttr.in/${1:-Salvador}?format=4"
}
```
