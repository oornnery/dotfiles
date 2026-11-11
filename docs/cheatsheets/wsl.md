# WSL

Arch runs inside WSL 2; Windows gives the terminal, the browser and the GPU. The
Linux side is the workstation. `dots wsl` is the command for everything in between.

## dots wsl

| Command | What it does |
| ------- | ------------ |
| `dots wsl` | Report: versions, `/etc/wsl.conf`, packages, `$HOME`; safe to paste |
| `dots wsl mount` | Mount Windows drives plugged in after WSL started (`-n` shows it) |
| `dots wsl windows -n` | Compare the configs in `windows/` with the Windows side |
| `dots wsl windows` | Copy them to Windows; what it replaces is kept as `.bak` |
| `dots wsl windows pull` | Bring back the ones changed on Windows |
| `dots wsl windows install [group]` | Windows packages by group (core, dev, game...) |
| `dots wsl windows export` | Save the installed winget packages |
| `dots wsl windows settings [-n]` | Windows settings (dark mode, taskbar, Alt+Tab...); `-n` tests |
| `dots wsl wslc ...` | The WSL container CLI (`wslc` alias) |

## The two config files

| File | Side | In the repo | After a change |
| ---- | ---- | ----------- | -------------- |
| `/etc/wsl.conf` | This distro: systemd, user, automount, Windows PATH off | `windows/wsl/wsl.conf` | `wsl --shutdown`, reopen |
| `%USERPROFILE%\.wslconfig` | The VM: 6 GB, 4 CPUs, mirrored network, sparse disk | `windows/wsl/.wslconfig` | `dots wsl windows`, then `wsl --shutdown` |

`appendWindowsPath=false`: Windows programs are not in `PATH`. Call them by path
(`/mnt/c/Windows/explorer.exe`) or through a wrapper: `browser` opens links,
`dots wsl wslc` runs wslc.

## From PowerShell

| Command | What it does |
| ------- | ------------ |
| `wsl --shutdown` | Stop WSL; the next terminal starts it with the new config |
| `wsl --list --verbose` | Distros, their state and WSL version |
| `wsl --update` | Update WSL and its kernel |
| `wsl --version` | WSL, kernel and WSLg versions |
| `wsl --export archlinux D:\arch.tar` | A full copy of the distro, to a file |
| `wsl --import name C:\WSL\name D:\arch.tar` | That copy as a new distro |
| `wsl --mount \\.\PHYSICALDRIVE1 --partition 1` | A disk in ext4, as admin; it shows in `/mnt/wsl` |

## Drives and files

- Windows drives connected when WSL starts are in `/mnt/c`, `/mnt/d`...; the ones
  plugged in later need `dots wsl mount` (or `dots install automount`, always).
- Linux files from Windows: `\\wsl.localhost\archlinux\home\oornnery` in Explorer.
- Work in the Linux side (`~/projects`): files under `/mnt/c` are much slower.
- `wslpath -w .` gives the Windows path of a folder; `wslpath -u 'C:\...'` the reverse.

## When something is off

| Symptom | Try |
| ------- | --- |
| A change in `wsl.conf` did nothing | `wsl --shutdown` from PowerShell |
| A drive is not in `/mnt` | `dots wsl mount` |
| Links do not open | `echo $BROWSER` in a new shell; it should be `~/.local/bin/browser` |
| No images in the terminal | Windows Terminal 1.22+ and `chafa` (`dots install yazi`) |
| Clock is behind after sleep | `sudo hwclock -s` |
