# Neovim

Two configs live side-by-side as **stow packages**:

| Package        | Distro     | Source                                                          |
| -------------- | ---------- | --------------------------------------------------------------- |
| `nvim/`        | mini.nvim  | hand-rolled, mini.nvim modules ([init.lua](../../../nvim/.config/nvim/init.lua)) |
| `nvim-lazyvim/`| LazyVim    | [LazyVim starter](https://github.com/LazyVim/starter) (clone)   |

Both target `~/.config/nvim` — you can only have one active at a time.

## Pick a distro

Edit [`scripts/arch/arch.conf`](../../../scripts/arch/arch.conf):

```bash
NVIM_DISTRO="mini"        # default
# NVIM_DISTRO="lazyvim"
```

Then re-run [`dev/stow.sh`](../../../scripts/arch/dev/stow.sh):

```bash
./scripts/arch/arch.sh dev/stow
```

It unstows the other and stows the chosen one. No data loss — both
configs remain in the repo.

## mini.nvim (default)

Lightweight, opinionated, native Lua. Plugins:

- mini.basics — sane defaults
- mini.surround — `sa`/`sd`/`sr` to add/delete/replace surrounds
- mini.comment — `gcc` to toggle line comment
- mini.pairs — auto pairs
- mini.indentscope — visual indent scope
- mini.animate — smooth scroll/cursor
- mini.statusline — minimal statusline
- LSP for Lua via `after/lsp/lua_ls.lua`
- Markdown ftplugin
- Snippets in `snippets/global.json`

Leader: `Space`. Run `:h mini.<module>` for help on each. Config lives
in `nvim/.config/nvim/plugin/{10_options,20_keymaps,30_mini,40_plugins}.lua`.

## LazyVim (alternative)

Heavier, plugin-rich, batteries included. Closer to what omarchy ships.
After switching, on first launch:

1. Lazy.nvim auto-installs everything (~30s)
2. Mason auto-installs LSP servers, formatters, linters

Leader: `Space`. Keymaps documented at <https://www.lazyvim.org/keymaps>.

> NOTE: `nvim-lazyvim/` is a stub today — clone
> <https://github.com/LazyVim/starter> into it on first setup.

## Common bindings (both distros)

| Bind              | Action                            |
| ----------------- | --------------------------------- |
| `Space Space`     | find file                         |
| `Space E`         | file explorer                     |
| `Space G G`       | LazyGit (if `lazygit` installed)  |
| `Space S F`       | live grep (ripgrep)               |
| `K`               | LSP hover                         |

Sudoedit alias: `sudoedit /etc/foo.conf` opens neovim as root via PAM
(no env leak).
