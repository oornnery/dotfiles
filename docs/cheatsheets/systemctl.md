# systemd

Services, timers and logs. The TUIs: `systemctl-tui` for units, `lazyjournal` for
logs. `--user` works on your own units, without sudo.

## Services

| Task | Command |
| ---- | ------- |
| State and last logs | `systemctl status docker` |
| Start, stop, restart | `sudo systemctl start docker` (`stop`, `restart`) |
| At boot, and now | `sudo systemctl enable --now docker` |
| Not at boot | `sudo systemctl disable --now docker` |
| What failed | `systemctl --failed` |
| Every service | `systemctl list-units --type=service` |
| Its unit file | `systemctl cat docker` |
| Change it, safely | `sudo systemctl edit docker` (an override), then `daemon-reload` |
| After editing a unit | `sudo systemctl daemon-reload` |

## Logs (journalctl)

| Task | Command |
| ---- | ------- |
| Of a service | `journalctl -u docker` |
| Follow | `journalctl -u docker -f` |
| This boot | `journalctl -b`, errors only: `journalctl -b -p err` |
| Since | `journalctl --since "1 hour ago"`, `--since today` |
| The kernel | `journalctl -k` (or `dmesg`) |
| Space used, trim | `journalctl --disk-usage`, `sudo journalctl --vacuum-time=2weeks` |

## Timers

| Task | Command |
| ---- | ------- |
| List | `systemctl list-timers` |
| Run something later | `systemd-run --user --on-active=10m notify-send "tea"` |

## Your own service

```ini
# ~/.config/systemd/user/api.service
[Unit]
Description=My API

[Service]
WorkingDirectory=%h/projects/api
ExecStart=%h/.local/bin/api
Restart=on-failure

[Install]
WantedBy=default.target
```

`systemctl --user daemon-reload && systemctl --user enable --now api`; logs:
`journalctl --user -u api -f`. A system one goes to `/etc/systemd/system/` (see
`system/` in the repo, like the drive automount).

## Boot time

`systemd-analyze`, the slow ones: `systemd-analyze blame`.
