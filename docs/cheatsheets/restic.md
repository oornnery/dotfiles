# Backup (restic)

`dots backup` saves the private files that are not in git (SSH keys, `.env` files) to a
Cloudflare R2 bucket, encrypted by restic. Set up with `dots install restic`.

| Task | Command |
| ---- | ------- |
| Save now, then drop old snapshots | `dots backup` |
| The snapshots | `dots backup list` |
| Restore the latest, verified | `dots backup restore [dir]` (default `~/restore`) |
| Add a file to the list | `dots backup paths`: one absolute path per line, no quotes |

A restore never overwrites in place: the files come back under the folder at their own
path, e.g. `~/restore/home/<you>/.ssh`. Copy back what you need, then delete the folder.

The retention runs on every save: the last 2, 7 daily, 4 weekly and 3 monthly snapshots.

## Files in `~/.config/restic`

- `paths`: what is saved. Starts with `~/.ssh`.
- `r2.env`: the repository address and R2 keys (see `r2.env.example`).
- `r2.password`: the repository password.

`r2.env` and `r2.password` never go in the list and never in the repo. Keep a copy of
both in your password manager: without them the backup cannot be opened if the distro
is lost. Save after you create or change a key or add a file to the list.
