# Fingerprint

Use the VAIO's fingerprint reader for `sudo`, console login, and polkit
prompts. Backed by [fprintd](https://fprint.freedesktop.org/) + PAM.

## Enable

```bash
# scripts/arch/arch.conf
ENABLE_FINGERPRINT=1
```

Then run:

```bash
./scripts/arch/arch.sh core/fingerprint
```

That installs `fprintd` + `libfprint` and patches:

- `/etc/pam.d/sudo`
- `/etc/pam.d/login`
- `/etc/pam.d/polkit-1`

Each gets `auth sufficient pam_fprintd.so` inserted before the first
`auth` line. Successful scan short-circuits past `pam_unix` — failed scan
falls through to the password prompt.

## Enroll a finger

After installation:

```bash
fprintd-enroll               # records the right index finger by default
fprintd-enroll -f left-thumb # specify a finger
fprintd-list "$USER"         # show what's enrolled
fprintd-verify               # test scan
```

You'll be asked to scan the same finger 5 times.

## Use

| Action            | Behaviour                                          |
| ----------------- | -------------------------------------------------- |
| `sudo <cmd>`      | scan finger → command runs; or `Ctrl+C` to skip to password |
| TTY login         | scan finger → logged in; or just type password     |
| Polkit prompt     | swipe to authorise (e.g. mounting an internal disk)|
| GDM/SDDM/greetd   | depends on DM — see notes below                    |

`Ctrl + C` at a fingerprint prompt always falls back to password.

## Display manager support

- **GDM** picks up `pam_fprintd` automatically — no extra config.
- **greetd + tuigreet** doesn't show a fingerprint prompt in the TUI,
  but PAM still accepts a scan if you tap during the password prompt.
- **SDDM** needs `pam_fprintd` added to `/etc/pam.d/sddm` manually if
  you want it on the lock screen.

## Reset / remove

```bash
fprintd-delete "$USER"                       # delete all enrolled prints
sudo pacman -Rns fprintd libfprint           # remove pkg
sudo sed -i '/pam_fprintd.so/d' /etc/pam.d/{sudo,login,polkit-1}
```

`core/fingerprint.sh` snapshots PAM files before patching — there's a
`.bak.<timestamp>` next to each if you need to roll back manually.
