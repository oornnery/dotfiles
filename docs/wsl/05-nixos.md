# NixOS on WSL (idea)

Status: an idea, nothing done. This page only records what would have to be mapped so a
decision can be made later.

The community [NixOS-WSL](https://github.com/nix-community/NixOS-WSL) project provides a
NixOS root filesystem for `wsl --import`.

## Mapping from the current setup

| Today                           | NixOS                                                        |
| ------------------------------- | ------------------------------------------------------------ |
| pacman explicit list            | `environment.systemPackages` or home-manager `home.packages` |
| paru / AUR packages             | nixpkgs, or an overlay                                       |
| uv tools, npm -g, cargo, bun -g | per-tool Nix packages, or keep them as user installs         |
| GNU Stow dotfiles               | home-manager `home.file` / `xdg.configFile`, or keep stow    |
| `/etc/wsl.conf`                 | `wsl.*` options of the module                                |
| `scripts/arch/*` bootstrap      | the flake itself                                             |

## Costs to weigh

- The whole `scripts/` bootstrap is Arch-shaped and would be replaced, not ported.
- Global npm and cargo tools and the agent CLIs update fast; pinning them in Nix adds
  work for little gain.
- Dynamically linked downloaded binaries do not run unpatched on NixOS.

## Before deciding

1. Keep [the inventory](02-inventory.md) current: it is the shopping list.
2. Try NixOS-WSL as a second, throwaway distro with `wsl --import`.
3. Decide per tool: managed by Nix, or installed at user level.

No flake or `configuration.nix` is written yet; add one only if the trial distro earns it.
