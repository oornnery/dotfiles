# Security

The defenses, in order of impact.

## 1. Encryption (LUKS) — opt-in at install time

archinstall offers it during partitioning. The previous `core/luks.sh`
that migrated initramfs hooks was removed (destructive, only useful once).

If you didn't pick LUKS at install:

- Set up encrypted volumes manually with `cryptsetup`
- Update `/etc/crypttab` + `/etc/mkinitcpio.conf` HOOKS
- Regenerate initramfs: `sudo mkinitcpio -P`

## 2. Firewall — ufw

[`core/ufw.sh`](../../../scripts/arch/core/ufw.sh) installs:

- `ufw` — opinionated wrapper around iptables/nftables
- `ufw-docker` — fixes UFW being bypassed by Docker's `iptables -t nat`

Defaults:

```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh                    # if you SSH in
sudo ufw allow 53317/udp              # LocalSend
sudo ufw enable
sudo systemctl enable --now ufw
```

Inspect rules:

```bash
sudo ufw status verbose
sudo ufw status numbered              # to delete by number
```

## 3. Sudo — wheel group only

[`core/user.sh`](../../../scripts/arch/core/user.sh) drops:

```text
%wheel ALL=(ALL:ALL) ALL
```

into `/etc/sudoers.d/10-wheel`. To require password on every sudo (no
caching), add `Defaults timestamp_timeout=0`. To never re-ask, set
`NOPASSWD` — don't.

## 4. Updates — rolling, atomic-ish

```bash
yay -Syu          # paru -Syu  — full system upgrade
                  # snap-pac snapshots before & after (rollback if it breaks)
```

The btrfs snapshot is the safety net — see [Snapshots](02-snapshots.md).

## 5. Secrets — gnome-keyring

[`core/keyring.sh`](../../../scripts/arch/core/keyring.sh) wires
`pam_gnome_keyring.so` into `/etc/pam.d/{login,gdm-password,passwd}`.
Login → keyring unlocks automatically → SSH keys and saved web auth
become available without re-entering the password.

Manage via `seahorse` (GUI) or `secret-tool` (CLI).

## What was removed

`core/hardening.sh` (AppArmor + usbguard) was deleted — both require
manual policy work after install. If you want them:

```bash
sudo pacman -S apparmor usbguard
sudo systemctl enable --now apparmor usbguard
# AppArmor: add  lsm=landlock,lockdown,yama,integrity,apparmor,bpf  to kernel cmdline
# usbguard: sudo usbguard generate-policy > /etc/usbguard/rules.conf
```

## Audit

```bash
arch-audit                           # known CVEs in installed packages
sudo lynis audit system              # generic Linux hardening sweep
```

`arch-audit` is in [`core/base-utils.sh`](../../../scripts/arch/core/base-utils.sh);
lynis you'd install on demand.
