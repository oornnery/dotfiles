# Debian on WSL

`scripts/debian-wsl.sh` bootstraps a terminal-only Debian distro: nala, base and modern
CLI tools, languages, the user, locale, `/etc/wsl.conf`, uv/starship/zoxide, Neovim and
the stowed dotfiles.

```bash
sudo bash scripts/debian-wsl.sh
sudo env USERNAME=name SKIP_PASSWD=1 bash scripts/debian-wsl.sh
```

Then run `wsl --shutdown` from PowerShell and reopen the distro.

## What was fixed

- The `fd`/`bat` links were created under `/home/<user>` before the user existed, which
  left a root-owned home. They are now created after the user, with correct ownership.
- The `wsl` stow package targets `/etc`; stowing it into `$HOME` created `~/etc`.
  It is no longer in the user stow list (the script installs `wsl.conf` itself).
- Neovim was compiled from source on every run. It now uses the upstream release
  tarball (x86_64); set `SKIP_NVIM_INSTALL=1` to skip.
- Removed `wl-clipboard`, `tesseract-ocr` and `libnotify-bin`, which only matter on a
  Wayland desktop.
- The stow step passed its variables through a double-quoted shell string. It now passes
  them as arguments.

## Checks

`bash -n scripts/debian-wsl.sh` passes. The script has not been run in a fresh Debian
distro as part of this change; do that in a throwaway distro first
(`wsl --install -d Debian --name debian-test`).
