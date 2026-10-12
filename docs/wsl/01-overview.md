# WSL overview

This machine runs Arch Linux inside WSL 2 and uses Windows only for the terminal,
the browser and the GPU. The Linux side is the real workstation; the Windows side is
documented under [`windows/`](../../windows/README.md).

## The three pieces

| Piece | What it is                                                                    | Used here                                                |
| ----- | ----------------------------------------------------------------------------- | -------------------------------------------------------- |
| WSL   | Linux distributions running in a lightweight VM with a Microsoft-built kernel | Arch (daily), Debian (secondary)                         |
| WSLg  | GUI layer: Linux Wayland/X11 apps show up as Windows windows                  | Available, rarely needed: the workflow is terminal-first |
| wslc  | WSL container CLI (`image`, `container`, `build`, `volume`, ...)              | Installed, see [wslc](03-wslc.md)                        |

Versions when this was written: WSL 3.0.1.0, kernel 6.18.40.1, WSLg 1.0.79.

## Layout

- Distros: `archlinux` (default, WSL 2) and the `docker-desktop` helper distro.
- `/etc/wsl.conf` comes from the `wsl/` stow package: systemd on, default user set,
  Windows interop and PATH on, generated hosts and resolv.conf.
- `windows/.wslconfig` holds the VM profile (memory, processors, swap, GPU). It is a
  Windows-side file: copy it to `%USERPROFILE%\.wslconfig` and run `wsl --shutdown`.
  When this doc was written no copy existed on the Windows side, so the VM was
  running with defaults.
- Shell: zsh with antigen; dotfiles are stowed from `~/dotfiles`.
- Multiplexer: herdr (see [herdr](../applications/herdr.md)); tmux and zellij remain
  available.

## Reload rules

- `wsl.conf` changes need `wsl --shutdown` from PowerShell, then reopen the distro.
- `.wslconfig` changes need the same.
- System stow packages (`wsl`, `zram`, ...) target `/etc`; never apply them as part of a
  user-level change. See [System stow](../configuration/08-system-stow.md).

## Where things live

| Question                            | Read                                       |
| ----------------------------------- | ------------------------------------------ |
| What is installed on this box?      | [Inventory](02-inventory.md)               |
| How do I run containers with wslc?  | [wslc](03-wslc.md)                         |
| How do I rebuild the Debian distro? | [Debian](04-debian.md)                     |
| What about NixOS-WSL?               | [NixOS idea](05-nixos.md)                  |
