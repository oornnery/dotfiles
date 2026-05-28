# Neovim Cheatsheet

The native config is the base. `nvim.lazy/` loads the same base first and then
adds plugins with lazy.nvim.

## Core

| Bind          | Action |
| ------------- | ------ |
| `<Space>`     | Leader |
| `<Space>w`    | Write file |
| `<Space>q`    | Quit window |
| `<Space>x`    | Write and quit |
| `<Space>?`    | Open cheatsheet |
| `:Helpme`     | Open helper |
| `:Cheatsheet` | Open helper |

## Files And Search

| Bind          | Action |
| ------------- | ------ |
| `<Space>e`    | Toggle netrw explorer |
| `<Space>E`    | Open netrw explorer |
| `<Space>ff`   | Find file with native `:find` |
| `<Space>sg`   | Search project with native `:vimgrep` |
| `<Space>rr`   | Change cwd to project root |

## Buffers And Quickfix

| Bind          | Action |
| ------------- | ------ |
| `<Space>bb`   | List and switch buffer |
| `<Space>bd`   | Delete buffer |
| `[b` / `]b`   | Previous / next buffer |
| `[q` / `]q`   | Previous / next quickfix item |
| `<Space>co`   | Open quickfix |
| `<Space>cc`   | Close quickfix |

## Windows And Terminal

| Bind          | Action |
| ------------- | ------ |
| `Ctrl-h/j/k/l`| Move between windows |
| `<Space>sv`   | Vertical split |
| `<Space>sh`   | Horizontal split |
| `<Space>=`    | Equalize windows |
| `<Space>tt`   | Terminal split |
| `Esc Esc`     | Leave terminal mode / clear search |

## Editing

| Bind          | Action |
| ------------- | ------ |
| `gcc`         | Toggle comment line |
| `gc`          | Toggle comment selection |
| `<` / `>`     | Indent visual selection and keep it selected |
| `<Space>f`    | Reindent file or visual selection |
| `<Space>tw`   | Toggle wrap |
| `<Space>ts`   | Toggle spell |

## lazy.nvim Extras

Only in `nvim.lazy/`:

| Bind           | Action |
| -------------- | ------ |
| `:Lazy`        | Plugin manager UI |
| `<leader>ha`   | Harpoon add file |
| `<leader>hh`   | Harpoon menu |
| `<leader>1..4` | Harpoon jump to pinned slot |
| `<leader>hn`   | Harpoon next |
| `<leader>hp`   | Harpoon previous |
| `zR`           | Open all folds with nvim-ufo |
| `zM`           | Close all folds with nvim-ufo |
| `zK`           | Peek fold or LSP hover |
| `Ctrl-a`       | dial.nvim increment |
| `Ctrl-x`       | dial.nvim decrement |

## Useful Commands

| Command            | Action |
| ------------------ | ------ |
| `:Root`            | Change cwd to project root |
| `:Search text`     | Search project into quickfix |
| `:TrimWhitespace`  | Trim trailing whitespace |
| `:Term`            | Open terminal split |
| `:MkSession`       | Save `.session.vim` |
| `:LoadSession`     | Load `.session.vim` |
