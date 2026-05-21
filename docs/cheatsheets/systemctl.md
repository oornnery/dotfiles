# Systemctl + Journalctl Cheatsheet

systemd service + log inspection. Most commands need `sudo`; `--user` runs
against the per-user instance (no sudo, manages units in `~/.config/systemd/user/`).

## Service control

| Command                          | What it does                       |
| -------------------------------- | ---------------------------------- |
| `sudo systemctl start <svc>`     | Start service (now)                |
| `sudo systemctl stop <svc>`      | Stop service (now)                 |
| `sudo systemctl restart <svc>`   | Stop + start                       |
| `sudo systemctl reload <svc>`    | Reload config (if supported)       |
| `sudo systemctl enable <svc>`    | Start on boot                      |
| `sudo systemctl disable <svc>`   | Don't start on boot                |
| `sudo systemctl enable --now <svc>` | Enable + start                   |
| `sudo systemctl mask <svc>`      | Block from being started (ever)    |
| `sudo systemctl unmask <svc>`    | Un-block                           |

## Status & inspection

| Command                          | What it does                          |
| -------------------------------- | ------------------------------------- |
| `systemctl status <svc>`         | Detailed status + recent logs         |
| `systemctl is-active <svc>`      | Just `active` / `inactive` / `failed` |
| `systemctl is-enabled <svc>`     | Just `enabled` / `disabled` / `masked`|
| `systemctl is-failed <svc>`      | Quick failure check                   |
| `systemctl list-units --failed`  | All failed units                      |
| `systemctl list-units --type=service` | All services on this boot        |
| `systemctl list-unit-files`      | All unit files (incl. disabled)       |
| `systemctl cat <svc>`            | Show unit file content                |
| `systemctl show <svc>`           | All properties (machine-readable)     |
| `systemctl --user status <svc>`  | Per-user instance                     |

## Targets (runlevels)

| Command                          | What it does                       |
| -------------------------------- | ---------------------------------- |
| `systemctl get-default`          | Default target (usually `graphical.target`) |
| `sudo systemctl set-default multi-user.target` | Boot to TTY (no DE)  |
| `systemctl isolate rescue.target`| Switch to rescue (single-user)     |
| `systemctl list-dependencies <target>` | What that target pulls in    |

## Power

| Command                          | What it does                  |
| -------------------------------- | ----------------------------- |
| `systemctl reboot`               | Reboot                        |
| `systemctl poweroff`             | Shutdown                      |
| `systemctl suspend`              | Suspend to RAM                |
| `systemctl hibernate`            | Hibernate (needs swap)        |
| `systemctl suspend-then-hibernate` | Suspend, then hibernate     |
| `systemctl rescue`               | Drop to rescue mode           |

## Editing units

```bash
# Edit unit (creates a drop-in at /etc/systemd/system/<svc>.d/override.conf)
sudo systemctl edit <svc>

# Full edit (replaces the unit file — careful)
sudo systemctl edit --full <svc>

# After any edit:
sudo systemctl daemon-reload
sudo systemctl restart <svc>
```

## Timers (cron alternative)

| Command                          | What it does                       |
| -------------------------------- | ---------------------------------- |
| `systemctl list-timers`          | All timers + next firing           |
| `systemctl list-timers --all`    | Include inactive                   |
| `systemctl cat <timer>.timer`    | Show timer definition              |
| `systemd-analyze calendar 'daily'` | Test calendar expressions         |
| `systemd-run --on-active=5m foo` | One-shot transient timer           |

## journalctl

| Command                              | What it does                          |
| ------------------------------------ | ------------------------------------- |
| `journalctl`                         | All logs (oldest first)               |
| `journalctl -e`                      | Jump to end                           |
| `journalctl -f`                      | Follow live (like `tail -f`)          |
| `journalctl -u <svc>`                | Logs for one service                  |
| `journalctl -u <svc> -f`             | Follow live for one service           |
| `journalctl -u <svc> --since today`  | Time filter                           |
| `journalctl --since '1 hour ago'`    | Relative time                         |
| `journalctl --since '2026-05-20 12:00' --until '2026-05-20 14:00'` | Range |
| `journalctl -b`                      | Current boot only                     |
| `journalctl -b -1`                   | Previous boot                         |
| `journalctl --list-boots`            | List all boots                        |
| `journalctl -p err`                  | Priority: only errors and worse       |
| `journalctl -p warning..err`         | Priority range                        |
| `journalctl -k`                      | Kernel messages only (`dmesg`-like)   |
| `journalctl --user -u <svc>`         | Per-user service logs                 |
| `journalctl -g 'pattern'`            | grep within logs                      |
| `journalctl --vacuum-time=7d`        | Purge logs older than 7 days          |
| `journalctl --disk-usage`            | How much disk the journal uses        |

## systemd-analyze

| Command                          | What it does                            |
| -------------------------------- | --------------------------------------- |
| `systemd-analyze`                | Total boot time                         |
| `systemd-analyze blame`          | Per-unit boot time (slowest first)      |
| `systemd-analyze critical-chain` | Boot critical path                      |
| `systemd-analyze plot > boot.svg`| SVG boot timeline                       |
| `systemd-analyze verify <unit>`  | Check unit file for errors              |
| `systemd-analyze security`       | Security score per service              |

## Common recipes

```bash
# Why did X fail?
systemctl status myservice
journalctl -u myservice -e --since '1 hour ago'

# What started in the last boot, sorted by time?
systemd-analyze blame | head -20

# Restart all .service units that are failed
systemctl --failed --no-legend | awk '{print $2}' | xargs -r sudo systemctl restart

# Show pending timer firings
systemctl list-timers --all
```

## Tips

| Tip                                              | Why it helps                            |
| ------------------------------------------------ | --------------------------------------- |
| `enable --now` is faster than two commands       | One step, common pattern                |
| `edit` creates a drop-in (not a full overwrite)  | Survives package upgrades               |
| `daemon-reload` after editing                    | systemd caches unit files               |
| `journalctl -u … -f` instead of `tail`           | Structured, time-sorted, multi-source   |
| Timers > cron (better logging, integration)      | `systemctl list-timers` is auditable    |
