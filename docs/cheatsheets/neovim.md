# Neovim Cheatsheet

The full config. Open the complete keys inside it with `<leader>?`.

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
| `Ctrl-h/j/k/l`| Move between windows; at a split edge, into the [herdr](herdr.md) pane |
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


## Useful Commands

| Command            | Action |
| ------------------ | ------ |
| `:Root`            | Change cwd to project root |
| `:Search text`     | Search project into quickfix |
| `:TrimWhitespace`  | Trim trailing whitespace |
| `:Term`            | Open terminal split |
| `:MkSession`       | Save `.session.vim` |
| `:LoadSession`     | Load `.session.vim` |
