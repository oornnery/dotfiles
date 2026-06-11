# Neovim

Three configs live side-by-side as mutually exclusive stow packages:

| Package      | Distro       | Shape |
| ------------ | ------------ | ----- |
| `nvim/`      | native       | Built-in Neovim only, no plugin manager |
| `nvim.lazy/` | lazy.nvim    | Sources `nvim/` first, then adds plugins |
| `nvim.mini/` | mini.nvim    | Separate mini.nvim-focused distro |

All target `~/.config/nvim`, so only one should be stowed at a time.

## Pick A Distro

Edit [`scripts/arch/arch.conf`](../../../scripts/arch/arch.conf):

```bash
NVIM_DISTRO="native"
# NVIM_DISTRO="lazy"
# NVIM_DISTRO="mini"
```

Then re-run [`dev/stow.sh`](../../../scripts/arch/dev/stow.sh):

```bash
./scripts/arch/arch.sh dev/stow
```

## Native Base

The native config is the source of truth for daily editor behavior:

- Leader is `Space`
- Custom statusline and theme loader
- `:Helpme`, `:Cheatsheet`, and `<Space>?`
- Netrw explorer, quickfix search, terminal split, sessions
- Native comment toggling and project-root helper

## lazy.nvim Variant

`nvim.lazy/` keeps the same native options, keymaps, statusline, cheatsheet,
and theme behavior. It only adds plugin extras through lazy.nvim, such as:

- `mini.nvim` modules for surround, comment, pairs, indentscope, and animation
- Harpoon pinned-file navigation
- render-markdown.nvim
- nvim-ufo folds
- dial.nvim smart increment/decrement
- smear-cursor.nvim cursor effect

Run `:Lazy` to manage plugins.

## mini.nvim Variant

`nvim.mini/` remains a separate mini.nvim distro. Use it when you want a
plugin-centered config instead of the strict native base.

## Common Bindings

| Bind          | Action |
| ------------- | ------ |
| `<Space>w`    | Write file |
| `<Space>q`    | Quit window |
| `<Space>e`    | Toggle netrw explorer |
| `<Space>ff`   | Native `:find` file lookup |
| `<Space>sg`   | Project search into quickfix |
| `<Space>bb`   | Switch buffer |
| `[b` / `]b`   | Previous / next buffer |
| `[q` / `]q`   | Previous / next quickfix item |
| `<Space>sv`   | Vertical split |
| `<Space>sh`   | Horizontal split |
| `<Space>tt`   | Terminal split |
| `<Space>?`    | Cheatsheet |
