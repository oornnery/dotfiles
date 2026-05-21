# Neovim (LazyVim) Cheatsheet

LazyVim distro + lazy.nvim plugin manager. Config in
`~/.config/nvim/lua/{config,plugins}/`. Leader is `<Space>`.

## Plugin manager

| Command        | What it does                                       |
| -------------- | -------------------------------------------------- |
| `:Lazy`        | Plugin manager UI (status, sync, install, etc.)    |
| `:Lazy sync`   | Update + install all plugins                       |
| `:Lazy clean`  | Remove unused plugins                              |
| `:Lazy profile`| Plugin startup-time profile                        |
| `:Mason`       | LSP / formatter / linter installer (under LazyVim) |
| `:checkhealth` | Diagnose missing deps, broken setups               |

## LazyVim core keymaps (telescope, neo-tree, buffers)

| Key         | Action                              |
| ----------- | ----------------------------------- |
| `<Space>ff` | Find files (telescope)              |
| `<Space>fg` | Live grep in project                |
| `<Space>fb` | Find buffers                        |
| `<Space>fr` | Recent files                        |
| `<Space>fc` | Find config files                   |
| `<Space>fn` | Find notifications                  |
| `<Space>e`  | Toggle file explorer (neo-tree)     |
| `<Space>w`  | Save file                           |
| `<Space>qq` | Quit all                            |
| `<Space>bd` | Delete buffer                       |
| `<Space>cd` | Change directory (CWD)              |
| `<Space>gg` | Open lazygit                        |
| `<Space>l`  | LazyVim menu                        |
| `<Space>x`  | Diagnostics / trouble panel         |

## Custom plugins (this dotfiles repo)

### Cursor effect — smear-cursor.nvim

| Key                | Action                                  |
| ------------------ | --------------------------------------- |
| (automatic)        | Smooth cursor trail effect while moving |

Config in `lua/plugins/cursor-effects.lua`. Tune `stiffness` /
`trailing_exponent` to adjust trail length and opacity.

### Markdown rendering — render-markdown.nvim

Renders headings / tables / code blocks / lists inline while editing MD.
Anti-conceal enabled: shows raw markup on the cursor line so you can edit
without losing context.

### Harpoon (v2) — pinned-file jumper

| Bind          | Action                          |
| ------------- | ------------------------------- |
| `<leader>ha`  | Add current file to list        |
| `<leader>hh`  | Open Harpoon quick menu         |
| `<leader>1..4`| Jump to pinned slot 1-4         |
| `<leader>hn`  | Cycle to next pinned            |
| `<leader>hp`  | Cycle to previous pinned        |

> List is per-project (cwd-scoped). Persists in `~/.local/share/nvim/harpoon/`.

### nvim-ufo — modern folding

| Key | Action                                          |
| --- | ----------------------------------------------- |
| `zR`| Open all folds                                  |
| `zM`| Close all folds                                 |
| `zK`| Peek folded lines (or LSP hover if not folded)  |
| `zc`| Close fold under cursor                         |
| `zo`| Open fold under cursor                          |
| `za`| Toggle fold under cursor                        |

Folds use LSP for languages with smart folding (TS/Go/Rust/…),
treesitter+indent fallback for vim/python/lua. Indicator on folded blocks
shows `+N lines` count.

### dial.nvim — smart Ctrl-a / Ctrl-x

| Bind            | Action                                                 |
| --------------- | ------------------------------------------------------ |
| `Ctrl + a`      | Increment (number / bool / date / day / month / hex)   |
| `Ctrl + x`      | Decrement (same)                                       |
| `g Ctrl + a/x`  | Cumulative (each line of visual selection by +N)       |

Examples: cursor on `true` → `Ctrl-a` → `false`. On `2026-05-21` → next day.
On `Monday` → `Tuesday`. On `#1a1b26` → bump hex by 1.

## mini.nvim modules (active here)

| Module             | What                                              |
| ------------------ | ------------------------------------------------- |
| `mini.basics`      | gdelete, gwipe, gmove                             |
| `mini.surround`    | `gsa<obj>` add, `gsd<obj>` delete, `gsr` replace  |
| `mini.comment`     | `gcc` line, `gc<motion>` over motion (treesitter) |
| `mini.pairs`       | Auto-close `()` `[]` `{}` `""` etc.               |
| `mini.indentscope` | `▎` symbol shows indent context                   |
| `mini.animate`     | Smooth scroll/resize/cursor motion (subtle)       |
| `mini.statusline`  | Lightweight bottom statusline                     |

## Useful built-in commands

| Command               | What                                  |
| --------------------- | ------------------------------------- |
| `:Telescope <picker>` | Run any telescope picker explicitly   |
| `:Trouble`            | Diagnostics / quickfix / lsp_refs UI  |
| `:Mason`              | LSP / DAP / formatter installer       |
| `:LspInfo`            | Active LSP clients for buffer         |
| `:LspRestart`         | Restart an LSP server                 |
| `:Format`             | Format with conform (or LSP fallback) |
| `:Lazy reload <name>` | Hot-reload a single plugin            |

## Window / buffer / tab management

| Bind          | Action                       |
| ------------- | ---------------------------- |
| `Ctrl-w h/j/k/l` | Move focus left/down/up/right |
| `Ctrl-w v`    | Vertical split               |
| `Ctrl-w s`    | Horizontal split             |
| `Ctrl-w =`    | Equalize sizes               |
| `Ctrl-w q`    | Close window                 |
| `Ctrl-w o`    | Close all OTHER windows      |
| `<S-h>` / `<S-l>` | Prev / next buffer       |
| `[b` / `]b`   | Prev / next buffer (alt)     |
| `<leader>bp`  | Toggle pin buffer (bufferline) |
| `<leader>bo`  | Close all OTHER buffers      |

## Examples

```vim
" Sync after editing plugin specs
:Lazy sync

" Quickly switch between 4 active files via harpoon
<Space>ha       " add current
<Space>1        " jump back to slot 1

" Smart incrementing
" In a markdown file with `- [ ] task` → cursor on the bracket → Ctrl-a → `- [x] task`

" Peek a fold without opening it
zK              " (ufo)
```

## Tips

| Tip                                              | Why it helps                            |
| ------------------------------------------------ | --------------------------------------- |
| Keep plugin specs short — one file per topic     | `:Lazy reload` works per file           |
| `:Lazy profile` after adding 5+ plugins          | Catches slow startup early              |
| Harpoon for the 3-4 files you touch most         | Cuts switching time by 90%              |
| `mini.animate` + `smear-cursor` — pick ONE       | They can compound and feel laggy        |
| `:checkhealth` before debugging weirdness        | First-line triage for misconfig         |
| Use treesitter text objects (`vif`, `daf`, …)    | Faster than visual + manual select      |
