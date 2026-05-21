# Pacman + Paru Cheatsheet

Arch package management. `pacman` for the official repos, `paru` for the AUR
(also wraps pacman so most flags work the same).

## Daily workflow (with aliases from this repo)

| Alias     | Expands to         |
| --------- | ------------------ |
| `update`  | `sudo pacman -Syu` |
| `install` | `sudo pacman -S`   |
| `remove`  | `sudo pacman -Rns` |
| `search`  | `pacman -Ss`       |
| `clean`   | `sudo pacman -Sc`  |

## Sync / install

| Command                       | What it does                            |
| ----------------------------- | --------------------------------------- |
| `sudo pacman -Syu`            | Sync DBs + upgrade everything           |
| `sudo pacman -Sy`             | Sync DBs only (rarely useful alone)     |
| `sudo pacman -Syyu`           | Force-resync DBs + upgrade              |
| `sudo pacman -S <pkg>`        | Install package                         |
| `sudo pacman -S --needed <p>` | Skip if already at latest               |
| `paru -S <pkg>`               | Install (repo or AUR)                   |
| `paru -Syu`                   | Upgrade everything incl. AUR            |
| `paru -Sua`                   | Upgrade AUR only                        |

## Remove

| Command                   | What it does                                |
| ------------------------- | ------------------------------------------- |
| `sudo pacman -R <pkg>`    | Remove package (keep deps)                  |
| `sudo pacman -Rs <pkg>`   | Remove + unused deps                        |
| `sudo pacman -Rns <pkg>`  | Remove + deps + config files (`.pacsave`)   |
| `sudo pacman -Rdd <pkg>`  | Force remove ignoring deps (DANGER)         |
| `pacman -Qdtq \| sudo pacman -Rns -` | Remove orphans                   |

## Query (read-only)

| Command           | What it does                          |
| ----------------- | ------------------------------------- |
| `pacman -Qs <p>`  | Search installed packages             |
| `pacman -Qi <p>`  | Detailed info on installed package    |
| `pacman -Ql <p>`  | List files installed by package       |
| `pacman -Qo <p>`  | Which package owns this file?         |
| `pacman -Qu`      | List pending upgrades                 |
| `pacman -Qdt`     | List orphaned deps                    |
| `pacman -Qe`      | List explicitly-installed (your set)  |
| `pacman -Qm`      | List foreign (AUR) packages           |
| `pacman -Qet`     | Explicitly installed not required     |

## Search remote

| Command          | What it does                       |
| ---------------- | ---------------------------------- |
| `pacman -Ss <p>` | Search repos                       |
| `pacman -Si <p>` | Info on a remote package           |
| `paru -Ss <p>`   | Search repos + AUR                 |
| `paru -Si <p>`   | Info on remote/AUR package         |

## Cache & cleanup

| Command                 | What it does                       |
| ----------------------- | ---------------------------------- |
| `sudo pacman -Sc`       | Remove uninstalled-pkg cache       |
| `sudo pacman -Scc`      | Remove ALL cache (be careful)      |
| `paru -c`               | Remove cached AUR build dirs       |
| `paccache -rk2`         | Keep only the 2 most recent ver.s  |
| `pacman-mirrors -f`     | Refresh mirrorlist (manjaro only)  |
| `sudo reflector --…`    | Refresh mirrorlist (vanilla Arch)  |

## Holds / ignore

```bash
# Pin to a version: edit /etc/pacman.conf, add IgnorePkg = linux linux-headers
# Or for one upgrade:
sudo pacman -Syu --ignore linux,linux-headers
```

## Logs / history

| Command                       | What it does                  |
| ----------------------------- | ----------------------------- |
| `tail /var/log/pacman.log`    | Last package operations       |
| `grep ' installed ' /var/log/pacman.log` | Install history    |
| `paclog --action=upgraded`    | If `pacutils` installed       |

## Downgrade

```bash
# Pick a version from the cache (or AUR `downgrade` helper):
ls /var/cache/pacman/pkg/ | grep <pkg>
sudo pacman -U /var/cache/pacman/pkg/<pkg>-<old-ver>.pkg.tar.zst
```

## AUR specifics

| Command                       | What it does                       |
| ----------------------------- | ---------------------------------- |
| `paru -Qua`                   | List AUR updates available         |
| `paru -G <pkg>`               | Clone PKGBUILD without installing  |
| `paru -Bi <pkg>`              | Build & install from local clone   |
| `paru --news`                 | Show Arch news (read before -Syu!) |

## Pacnew / pacsave

After upgrades, `.pacnew` files appear when you've edited a config:

| Tool        | What it does                             |
| ----------- | ---------------------------------------- |
| `pacdiff`   | Interactive merge of `.pacnew/.pacorig`  |
| `find /etc -name '*.pacnew'` | List pending merges       |

## Tips

| Tip                                                | Why it helps                          |
| -------------------------------------------------- | ------------------------------------- |
| `--needed` on every `-S`                           | Idempotent installs (no reinstall)    |
| Run `paru --news` before big `-Syu`                | Catches manual-intervention notes     |
| `pacman -Qet` ≈ "stuff I asked for"                | Build a portable install list         |
| Don't `-Syyu` casually                             | Forces re-DL of every DB              |
| `paccache -rk2` weekly cron                        | Keeps `/var/cache/pacman/` bounded    |
| Read `.pacnew` after each upgrade                  | Prevents silent config drift          |
