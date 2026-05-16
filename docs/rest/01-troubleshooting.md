# Troubleshooting

## Hyprland won't start after a reload

```bash
hyprctl reload          # check stderr in the journal
journalctl --user -b -u Hyprland | tail
```

Common causes:

- Syntax error in `bindings.conf` or `monitors.conf` — open the file and
  read the line number from the error
- Missing executable referenced in `exec-once` (e.g. `swayosd-server` not
  installed) — install or comment out

## Pendrive doesn't show up

Order of investigation:

```bash
lsusb            # detected at USB bus level?  (needs usbutils, in base-utils)
lsblk            # detected as a block device?
dmesg | tail     # any errors at the kernel level?
systemctl status udisks2  # mount daemon up?
```

On Hyprland, `udiskie` must be running:

```bash
pgrep -a udiskie || udiskie --automount --notify --tray &
```

On GNOME, Nautilus handles it via gvfs — no extra daemon needed.

## Sound vanished

```bash
systemctl --user status pipewire pipewire-pulse wireplumber
wpctl status                          # graph + default sink
pavucontrol                           # GUI per-app volume / device pick
```

If wireplumber crashed: `systemctl --user restart pipewire pipewire-pulse wireplumber`.

## Wi-Fi reconnect after sleep

NetworkManager should handle it. If it doesn't:

```bash
sudo systemctl restart NetworkManager
```

On iwd backend, `impala` (TUI) plus `iwctl` are the rescue tools.

## TUI fingerprint blocks login

Hit `Ctrl + C` at any `pam_fprintd.so` prompt → falls through to
password. To remove permanently:

```bash
sudo sed -i '/pam_fprintd.so/d' /etc/pam.d/{sudo,login,polkit-1}
```

## `arch.sh` keeps re-running things

Modules use `--needed` on pacman; reinstalls are silent no-ops. Repeated
"installing X" logs are cheap. If a module is making changes you don't
want, run it once and remove from `ALL_PRESET` in `arch.sh`.

## Where is the log

`scripts/arch/lib/arch.log` (gitignored). Tailing helps:

```bash
tail -f scripts/arch/lib/arch.log
```
