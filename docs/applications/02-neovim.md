# Neovim and Vim

The maintained daily config is `nvim/.config/nvim/` (Neovim 0.12+, lazy.nvim).
The Arch selector calls this package `NVIM_DISTRO="native"` for historical reasons;
it does have plugins. `nvim.mini/` and `nvim.lazy/` are alternative, mutually
exclusive Stow packages, not layers required by the active setup.

`vim/.vimrc` is the native-only companion (`VIM_DISTRO="native"`). It uses Vim's
built-in netrw, completion, quickfix, terminal, comments and statusline; no external
plugins, language servers or AI extensions. Functional equivalents share shortcuts,
but native reindentation is not an LSP formatter and `:find` is not a fuzzy picker.

## Shared workflow

Leader is `Space` in both editors.

| Shortcut                              | Neovim                             | Vim (no external plugins)  |
| ------------------------------------- | ---------------------------------- | -------------------------- |
| `<Space>w`, `<Space>q`, `<Space>x`    | Save, quit, save+quit              | Same                       |
| `<Space>e`                            | Neo-tree; netrw in basic mode      | netrw sidebar              |
| `<Space>ff`                           | fzf files                          | Native `:find`             |
| `<Space>fg`                           | fzf live grep                      | `:Search` into quickfix    |
| `<Space>bb`, `[b`, `]b`               | Switch buffers                     | Same                       |
| `<Space>sv`, `<Space>sh`              | Split windows                      | Same                       |
| `<Space>rr`                           | Change to project root             | Same                       |
| `<Space>cf`                           | Configured formatter               | Native reindentation       |
| `gcc`, visual `gc`                    | Comment toggle                     | Native comment helper      |
| `<Space>tt`, `<Space>tv`, `<Space>th` | Terminal float/vertical/horizontal | Native terminal splits     |
| `<Space>?`                            | Cheatsheet                         | Cheatsheet via `dots help` |

## MobaXterm / limited terminals

Start on the remote host with:

```bash
DOTFILES_TERMINAL=basic nvim
DOTFILES_TERMINAL=basic vim
```

Basic mode uses terminal colors, an ASCII statusline/list markers and no mouse
capture. Neovim keeps editing/LSP plugins but skips animated cursor, Noice/notify,
bufferline, Neo-tree and rendered Markdown. Oil/fzf omit file icons. Terminal key
sequences have a 100 ms timeout instead of the previous 10 ms.

Automatic basic mode recognizes `TERM_PROGRAM` containing `moba` and Linux TTYs.
SSH often forwards only `TERM`, so set the override on the remote host when needed.
Use `DOTFILES_TERMINAL=full` to override detection. This does not force RGB colors.
Do not globally fake `TERM` or `COLORTERM`; they must describe the actual terminal.
For full icon rendering, configure a Nerd Font in the Windows terminal itself.

Compare inside/outside Herdr or tmux. The tmux config still advertises RGB and
extended keys for generic xterm clients; test directly if display or keys differ.
MobaXterm visual correctness must be confirmed on Windows, not by a headless test.

For a no-plugin baseline without downloading anything:

```bash
DOTFILES_TERMINAL=basic DOTFILES_NVIM_PLUGINS=0 nvim
```

If lazy.nvim cannot be downloaded on a new host, startup now continues with native
editing and a warning, instead of waiting for a key and exiting. In regular mode,
Oil loads at startup so opening a directory does not depend on first invoking a key.

## Verification

```bash
python3 scripts/test-editors.py
```

The tests cover both editors in full/basic native mode: startup, shared mappings,
Python comments/indentation, project-root navigation and directory browsing. They
do not emulate MobaXterm or contact an AI provider. See the
[Neovim guide](../../nvim/.config/nvim/README.md) for the normal plugin stack.
