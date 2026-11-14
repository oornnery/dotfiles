# restic and backup

`backup` saves the private files that are not in git (SSH keys, `.env` files) to a
Cloudflare R2 bucket, encrypted by restic. Set up with `dots install restic`.

| Task | Command |
| ---- | ------- |
| Save now | `backup` |
| What is saved | `cat ~/.config/restic/paths` |
| Add a file | `hx ~/.config/restic/paths`, one absolute path per line, no quotes |
| Snapshots | `restic snapshots` (needs `set -a; . ~/.config/restic/r2.env; set +a`) |
| Restore a snapshot | `restic restore latest --target /tmp/restore --tag wsl` |

## Files in `~/.config/restic`

- `paths`: what `backup` saves. Starts with `~/.ssh`.
- `r2.env`: the repository address and R2 keys (see `r2.env.example`).
- `r2.password`: the repository password.

`r2.env` and `r2.password` never go in the list and never in the repo. Keep a copy of
both in your password manager: without them the backup cannot be opened if the distro is lost.
