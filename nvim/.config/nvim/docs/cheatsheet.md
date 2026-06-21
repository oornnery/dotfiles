# Neovim quick help

> Press `q` to close this page. Leader key = `<Space>`.

## Mental model

- Normal mode: move, run commands, operate on text. Press `<Esc>` to return here.
- Insert mode: type text. Enter with `i`, `a`, `o`, `O`.
- Visual mode: select text. Enter with `v`, `V`, `<C-v>`.
- Command mode: run commands. Enter with `:`.
- Terminal mode: terminal input. Leave with `<Esc><Esc>`.

## Survival keys

| Key          | Action                           |
| ------------ | -------------------------------- |
| `<Esc>`      | leave insert/visual mode         |
| `:w`         | save                             |
| `:q`         | quit window                      |
| `:wq` / `:x` | save and quit                    |
| `:qa`        | quit all                         |
| `u`          | undo                             |
| `<C-r>`      | redo                             |
| `.`          | repeat last edit                 |
| `q`          | close help/quickfix-like windows |

## Movement

| Key               | Action                                 |
| ----------------- | -------------------------------------- |
| `h` `j` `k` `l`   | left/down/up/right                     |
| `w` / `b` / `e`   | next word / previous word / end word   |
| `0` / `^` / `$`   | line start / first nonblank / line end |
| `gg` / `G`        | file top / file bottom                 |
| `<C-d>` / `<C-u>` | half page down/up                      |
| `%`               | matching bracket                       |
| `*`               | search word under cursor               |
| `/text`           | search text                            |
| `n` / `N`         | next / previous search match           |

## Editing basics

| Key                 | Action                         |
| ------------------- | ------------------------------ |
| `i` / `a`           | insert before / after cursor   |
| `o` / `O`           | new line below / above         |
| `x`                 | delete char                    |
| `dd`                | delete line                    |
| `yy`                | copy line                      |
| `p` / `P`           | paste after / before           |
| `ciw`               | change inner word              |
| `diw`               | delete inner word              |
| `gcc`               | toggle comment line            |
| `gc` in visual      | toggle comment selection       |
| `<` / `>` in visual | indent left/right and reselect |

## Your leader shortcuts

| Key                         | Action                        |
| --------------------------- | ----------------------------- |
| `<leader>?`                 | open this help                |
| `<leader>w`                 | write file                    |
| `<leader>q`                 | quit window                   |
| `<leader>x`                 | write and quit                |
| `<leader>bb`                | switch buffer prompt          |
| `<leader>bd`                | delete buffer                 |
| `[b` / `]b`                 | previous / next buffer        |
| `<S-h>` / `<S-l>`           | previous / next buffer tab    |
| `<leader>bp`                | pick buffer tab               |
| `<leader>bP`                | pick buffer tab to close      |
| `<leader>bo`                | close other buffers           |
| `<leader>br` / `<leader>bl` | close buffers right / left    |
| `<leader>co` / `<leader>cc` | open / close quickfix         |
| `[q` / `]q`                 | previous / next quickfix item |
| `<leader>rr`                | cd to project root            |
| `<leader>tw`                | toggle wrap                   |
| `<leader>ts`                | toggle spell                  |
| `<leader>tc`                | toggle treesitter context     |

## Files and search (fzf-lua)

| Key                         | Action                       |
| --------------------------- | ---------------------------- |
| `<leader>ff`                | find files                   |
| `<leader>fg`                | live grep project            |
| `<leader>fb`                | open buffers                 |
| `<leader>fo`                | recent files                 |
| `<leader>fh`                | help tags                    |
| `<leader>fk`                | all keymaps                  |
| `<leader>fr`                | resume last picker           |
| `<leader>fs` / `<leader>fS` | document / workspace symbols |

## File explorers

| Key             | Action                             |
| --------------- | ---------------------------------- |
| `<leader>e`     | toggle Neo-tree sidebar            |
| `<leader>E`     | Neo-tree float/reveal current file |
| `<leader>ge`    | Neo-tree git status source         |
| `<leader>be`    | Neo-tree buffers source            |
| `H` in Neo-tree | toggle hidden files                |
| `/` in Neo-tree | fuzzy filter tree                  |
| `-`             | Oil parent directory buffer        |
| `<leader>o`     | open Oil directory buffer          |
| `<leader>O`     | open Oil floating window           |
| `<CR>` in Oil   | open file/dir                      |
| `g?` in Oil     | Oil help                           |

## Windows

| Key                             | Action               |
| ------------------------------- | -------------------- |
| `<C-h>` `<C-j>` `<C-k>` `<C-l>` | move between windows |
| `<leader>sv`                    | vertical split       |
| `<leader>sh`                    | horizontal split     |
| `<leader>=`                     | equalize windows     |

## LSP / code

Only works when a language server is attached.

| Key                         | Action                             |
| --------------------------- | ---------------------------------- |
| `gd`                        | goto definition                    |
| `gr`                        | references                         |
| `gI`                        | goto implementation                |
| `gy`                        | goto type definition               |
| `K`                         | hover docs                         |
| `<leader>ca`                | code action                        |
| `<leader>crn`               | rename symbol                      |
| `<leader>cf`                | format buffer                      |
| `[d` / `]d`                 | previous / next diagnostic         |
| `<leader>qf`                | diagnostics to location list       |
| `<leader>dd` / `<leader>dD` | all / buffer diagnostics (Trouble) |
| `<leader>ds`                | document symbols (Trouble)         |
| `<leader>dl`                | LSP refs/defs (Trouble)            |
| `<leader>dq`                | quickfix list (Trouble)            |

## Git hunks (gitsigns)

| Key                         | Action                       |
| --------------------------- | ---------------------------- |
| `[c` / `]c`                 | previous / next git hunk     |
| `<leader>hs` / `<leader>hr` | stage / reset hunk           |
| `<leader>hS` / `<leader>hR` | stage / reset buffer         |
| `<leader>hp`                | preview hunk                 |
| `<leader>hb`                | blame line                   |
| `<leader>hd`                | diff this                    |
| `ih` in visual/operator     | select hunk                  |
| `]t` / `[t`                 | next / previous TODO comment |
| `<leader>dt` / `<leader>dT` | TODOs in Trouble / quickfix  |

## Fast movement and text objects

| Key         | Action                                                  |
| ----------- | ------------------------------------------------------- |
| `s`         | flash jump to visible text                              |
| `S`         | flash treesitter jump                                   |
| `gsa`       | add surround, example `gsaw)` wraps word in parentheses |
| `gsd`       | delete surround                                         |
| `gsr`       | replace surround                                        |
| `af` / `if` | around / inside function textobject (mini.ai)           |
| `aa` / `ia` | around / inside argument textobject (mini.ai)           |

## Markdown

| Key                      | Action                         |
| ------------------------ | ------------------------------ |
| `<leader>mp`             | toggle inline markdown preview |
| `:RenderMarkdown toggle` | same action by command         |

## Completion (blink.cmp)

| Key         | Action                                      |
| ----------- | ------------------------------------------- |
| `<Tab>`     | accept/select completion (super-tab preset) |
| `<S-Tab>`   | previous completion item                    |
| `<C-space>` | show completion/docs                        |
| `<C-e>`     | hide completion menu                        |

## AI

| Key                         | Action                             |
| --------------------------- | ---------------------------------- |
| `<leader>aa`                | CodeCompanion action palette       |
| `<leader>ac`                | toggle AI chat                     |
| `<leader>aC`                | open AI chat                       |
| `<leader>ad` in visual      | add selection to chat              |
| `<leader>ai`                | inline AI prompt                   |
| `<leader>ae` in visual      | explain selection                  |
| `<leader>af` in visual      | fix selection                      |
| `<leader>at` in visual      | generate tests for selection       |
| `<leader>am`                | AI command helper                  |
| `<leader>ao` / `<leader>aO` | OpenCode float / vertical terminal |
| `<leader>as`                | toggle Minuet inline AI completion |
| `<leader>aS`                | toggle Minuet in completion menu   |
| `<leader>aM`                | pick/change Minuet model           |
| `<leader>aP`                | change Minuet provider             |
| `<A-y>` in completion menu  | request/accept Minuet completion   |
| `<C-l>` in insert           | accept Minuet inline suggestion    |
| `<C-j>` in insert           | accept Minuet inline line          |
| `<A-n>` / `<A-p>` in insert | next / previous Minuet suggestion  |
| `<C-]>` in insert           | dismiss Minuet suggestion          |

Minuet default is local-first. If `ollama` exists, it uses `http://localhost:11434/v1/completions` with `qwen2.5-coder:7b`.

Useful overrides:

```sh
MINUET_MODEL=deepseek-coder-v2:16b nvim
MINUET_ENDPOINT=http://localhost:11434/v1/completions nvim
MINUET_PROVIDER=openai_compatible nvim
```

## Terminal

| Key          | Action                               |
| ------------ | ------------------------------------ |
| `<leader>tt` | floating terminal                    |
| `<leader>tv` | vertical terminal                    |
| `<leader>th` | horizontal terminal                  |
| `<leader>ao` | OpenCode terminal float              |
| `<leader>aO` | OpenCode terminal vertical           |
| `<Esc><Esc>` | terminal normal mode                 |
| `<C-\>`      | toggle terminal (toggleterm default) |

## UI / sessions

| Key                         | Action                           |
| --------------------------- | -------------------------------- |
| `<leader>nn`                | Noice message history            |
| `<leader>nl`                | show last message                |
| `<leader>ne`                | show Noice errors                |
| `<leader>nd`                | dismiss messages                 |
| `<leader>np`                | pick messages                    |
| `<leader>nf`                | search messages with fzf-lua     |
| `<leader>nD` / `<leader>nE` | disable / enable Noice           |
| `<S-Enter>` in command mode | redirect command output to popup |
| `<C-f>` / `<C-b>`           | scroll hover/signature docs      |
| `<leader>ps`                | restore session for project      |
| `<leader>pS`                | pick session                     |
| `<leader>pl`                | restore last session             |
| `<leader>pd`                | stop saving session              |

## Learning flow

1. Use `i` to type, `<Esc>` to stop typing.
2. Use `<leader>e` for file sidebar, `<leader>ff` to find files, `<leader>fg` to search text.
3. Use `gd`, `K`, `<leader>ca`, `<leader>cf` for code.
4. Use `<leader>fk` when you forget a keymap.
5. Use `:help <topic>` for official help, example: `:help motion.txt`.
