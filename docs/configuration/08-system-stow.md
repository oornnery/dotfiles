# System stow (`/etc/` via GNU stow)

This setup uses GNU Stow not only for user dotfiles in `$HOME` but also
for a handful of system config files in `/etc/`. This page documents
the approach, the rules of thumb, and the corner cases.

## What's stowed into `/`

Five packages at the repo root mirror a subtree of `/etc/`:

| Stow package | Target file                                              | Read by         |
| ------------ | -------------------------------------------------------- | --------------- |
| `greetd/`    | `/etc/greetd/config.toml`                                | greetd          |
| `gdm/`       | `/etc/gdm/custom.conf`                                   | gdm             |
| `iwd/`       | `/etc/NetworkManager/conf.d/wifi_backend.conf`           | NetworkManager  |
| `wsl/`       | `/etc/wsl.conf`                                          | WSL host        |
| `zram/`      | `/etc/systemd/zram-generator.conf`                       | systemd zram-gen |

Each gets linked via the [`stow_system`](../../scripts/arch/lib/common.sh)
helper:

```bash
stow_system <package>     # sudo stow -d $DOTFILES_DIR -t / -R <package>
```

Before stowing, real-file conflicts under `/` are backed up to
`*.bak.<timestamp>`.

## Why stow into `/etc/`

- **Edit-in-place.** Open the file in the repo, save, reload the service.
  No "edit then re-run installer" loop.
- **Git tracks the truth.** Diff against history; revert via `git checkout`.
- **Same workflow as `$HOME` dotfiles.** One mental model.
- **Atomic switching.** `stow -D pkg` removes the symlinks; default
  pacman-shipped file (if any) reappears or you write your own.

## When `stow_system` is safe

The config file must be read *after* `/home` (or wherever the repo
lives) is mounted. On a typical Arch install with `/home` as a btrfs
subvolume of root, every file under `/etc/` is reachable once the root
fs is up.

Safe categories:

- Display manager configs (greetd, gdm, sddm) — read at
  `display-manager.target`, late in boot.
- NetworkManager / iwd configs — read on `basic.target`.
- systemd unit / generator configs that run **after** `local-fs.target`.
- WSL `wsl.conf` — single fs, no ordering risk.
- Any service config you can reload at runtime (`systemctl restart`,
  `makoctl reload`, etc.).

## When **NOT** to stow into `/etc/`

| Path                                          | Why not                                                                    |
| --------------------------------------------- | -------------------------------------------------------------------------- |
| `/etc/fstab`                                  | Read by the initramfs **before** any partition is mounted.                |
| `/etc/crypttab`                               | Same — initramfs reads it to unlock encrypted volumes.                    |
| `/etc/mkinitcpio.conf`                        | `mkinitcpio -P` runs from rescue shells where `/home` may not be present. |
| Bootloader configs (`/boot/loader/entries/*`) | Read by the bootloader **before** any OS code runs.                       |
| `/etc/sudoers`, `/etc/sudoers.d/*`            | `sudo` **refuses** files whose path traverses a symlink (hardcoded).      |
| `/etc/passwd`, `/etc/shadow`, `/etc/group`    | libc reads these very early; daemons need them at start-up.               |
| `/etc/pacman.conf`                            | pacman owns it; `.pacnew` semantics get weird through a symlink.           |
| Anything boot-critical or security-sensitive  | The risk-reward isn't there.                                              |

For these, use the older "install/copy" pattern (template + `install -m`
in a script) instead.

## Pitfalls (even on the safe paths)

### `.pacnew` files

When the upstream package (e.g. `systemd`, `gdm`) updates and ships a
new default for a config you stow, pacman writes
`/etc/<file>.pacnew` next to the existing symlink. The symlink keeps
pointing at your version; pacman doesn't know to merge.

Workflow:

```bash
pacdiff                          # or: meld /etc/foo /etc/foo.pacnew
```

Roughly every `paru -Syu` after a relevant upgrade. Same pattern as if
you'd modified the real file in place — stow doesn't make it worse, but
it doesn't make it better either.

### Separate `/home` partition

Currently, this machine has `/home` as a btrfs subvolume of `/`, so
`/etc/foo → /home/user/dotfiles/foo` resolves trivially during boot.

If you later install with `/home` on a **separate** partition that
mounts after `basic.target`, early services that read stowed
`/etc/` files (notably `systemd-zram-setup@zram0.service`) will see a
dangling symlink and fail silently.

Mitigation when that day comes: switch zram (and any other early-boot
file) back to the install/copy pattern. The other four packages are
unaffected (they all start much later in boot).

### Rescue / single-user mode

A symlink under `/etc/` that points into `/home` is broken if `/home`
isn't mounted. Booting into `systemd.unit=rescue.target` typically
mounts root only.

Affected: any of the five files referenced by a service that runs in
rescue mode. In practice none of greetd/gdm/iwd/wsl/zram are needed
in rescue, so this is theoretical.

### `pacman -Qkk` flags modifications

`pacman -Qkk <pkg>` verifies file integrity against the install
manifest. Stowed files show as "modified" because they're symlinks,
not the original real files.

Cosmetic only — no behaviour change. Filter with `grep -v '^backup'`
or accept the noise.

## Adding a new system stow package

Same recipe as the five existing ones:

1. Mirror the target tree at the repo root:

   ```bash
   mkdir -p mypkg/etc/mything
   cp /etc/mything/config.conf mypkg/etc/mything/config.conf
   $EDITOR mypkg/etc/mything/config.conf   # change what you need
   ```

2. Add a call from the relevant module (or create one):

   ```bash
   # scripts/arch/core/mything.sh
   source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
   require_root
   log::banner "Core" "MyThing"
   sudo pacman -S --needed --noconfirm mything
   stow_system mypkg
   sudo systemctl restart mything.service
   ```

3. (Optional) add to `arch.sh` `MODULES_DESC` + `SECTION_<section>`.

That's it. `stow_system` handles backup-and-link automatically.

## Removing a stow

```bash
sudo stow -d ~/dotfiles -t / -D mypkg     # remove symlinks
# /etc/<file> now missing — restore with `pacman -S --force` or
# from /etc/<file>.bak.<timestamp> created at the original stow time.
```

## See also

- [stow cheatsheet](../cheatsheets/stow.md)
- [Dotfiles (Stow)](05-dotfiles.md) — the user-side equivalent in `$HOME`
- [`scripts/arch/lib/common.sh`](../../scripts/arch/lib/common.sh) —
  `stow_safe` (for `$HOME`) and `stow_system` (for `/`)
