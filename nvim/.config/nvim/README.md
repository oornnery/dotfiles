# Neovim setup

Personal Neovim configuration. Modular, lazy-loaded, tuned for daily development.

## Structure

```text
~/.config/nvim/
├── init.lua                  entry point
├── README.md                 this file
├── lazy-lock.json            pinned plugin versions
├── docs/
│   └── cheatsheet.md         quick help (open with :Helpme or <leader>?)
├── lua/
│   ├── theme.lua             custom theme loader (dots theme system)
│   ├── statusline.lua        pure Lua statusline
│   ├── cheatsheet.lua        reads docs/cheatsheet.md into a buffer
│   ├── config/
│   │   ├── options.lua       vim.opt settings
│   │   ├── lazy.lua          plugin manager bootstrap
│   │   ├── autocmds.lua      autocommands + user commands
│   │   └── keymaps.lua       base keymaps (plugin maps live in specs)
│   └── plugins/
│       ├── ai.lua            CodeCompanion + Minuet completions
│       ├── blink.lua         blink.cmp completion engine
│       ├── diagnostics.lua   Trouble + todo-comments
│       ├── editor.lua        Neo-tree, Oil, gitsigns, smear-cursor, autopairs
│       ├── fzf.lua           fzf-lua fuzzy finder
│       ├── lsp.lua           treesitter, mason, LSP servers, conform
│       ├── markdown.lua      render-markdown inline preview
│       ├── navigation.lua    flash, mini.surround, mini.ai, indent-blankline, treesitter-context
│       ├── sessions.lua      persistence session manager
│       ├── terminal.lua      toggleterm + opencode shortcuts
│       └── ui.lua            bufferline, noice, notify, which-key
```

## Plugin manager

[lazy.nvim](https://github.com/folke/lazy.nvim) — auto-bootstraps on first launch. Plugins are declared in `lua/plugins/*.lua` and lazy-loaded by event, command, or keymap.

## Plugins

### Completion & LSP

| Plugin                                                                       | What it does                                                                              |
| ---------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------- |
| [blink.cmp](https://github.com/saghen/blink.cmp)                             | Completion engine (Rust fuzzy matcher). Sources: LSP, path, snippets, buffer, Minuet AI.  |
| [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)                   | LSP server configs via `vim.lsp.config()` (nvim 0.11+ API).                               |
| [mason.nvim](https://github.com/williamboman/mason.nvim)                     | Install LSP servers, formatters, linters.                                                 |
| [mason-lspconfig.nvim](https://github.com/williamboman/mason-lspconfig.nvim) | Bridge mason → LSP config. Auto-installs ensured servers.                                 |
| [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)        | Syntax highlighting, folding, incremental selection. Branch `main` (new API, nvim 0.12+). |
| [conform.nvim](https://github.com/stevearc/conform.nvim)                     | Format on save. Formatters per filetype.                                                  |
| [lazydev.nvim](https://github.com/folke/lazydev.nvim)                        | Lua LSP completions for nvim config/plugin development.                                   |

### Navigation & search

| Plugin                                                                                | What it does                                                                     |
| ------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------- |
| [fzf-lua](https://github.com/ibhagwan/fzf-lua)                                        | Fuzzy finder (files, grep, buffers, symbols, keymaps, help). Wraps `fzf` binary. |
| [flash.nvim](https://github.com/folke/flash.nvim)                                     | Jump to any visible word with labels. Replaces `s`/`S`/`r`/`R`.                  |
| [mini.surround](https://github.com/echasnovski/mini.surround)                         | Add/delete/replace surrounding pairs (`gsa`, `gsd`, `gsr`).                      |
| [mini.ai](https://github.com/echasnovski/mini.ai)                                     | Better text objects (`ia`, `aa`).                                                |
| [indent-blankline.nvim](https://github.com/lukas-reineke/indent-blankline.nvim)       | Indentation guides.                                                              |
| [nvim-treesitter-context](https://github.com/nvim-treesitter/nvim-treesitter-context) | Show current function/class context at top of window.                            |

### File explorers

| Plugin                                                          | What it does                                                            |
| --------------------------------------------------------------- | ----------------------------------------------------------------------- |
| [neo-tree.nvim](https://github.com/nvim-neo-tree/neo-tree.nvim) | Persistent sidebar file tree. Sources: filesystem, buffers, git_status. |
| [oil.nvim](https://github.com/stevearc/oil.nvim)                | Edit directories as buffers. `-` opens parent directory.                |

### Git

| Plugin                                                      | What it does                                                      |
| ----------------------------------------------------------- | ----------------------------------------------------------------- |
| [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim) | Git hunks in sign column. Stage/reset/preview hunks, blame, diff. |

### UI

| Plugin                                                                               | What it does                                                         |
| ------------------------------------------------------------------------------------ | -------------------------------------------------------------------- |
| [bufferline.nvim](https://github.com/akinsho/bufferline.nvim)                        | Top buffer tabs.                                                     |
| [noice.nvim](https://github.com/folke/noice.nvim)                                    | Modern cmdline, messages, popupmenu.                                 |
| [nvim-notify](https://github.com/rcarriga/nvim-notify)                               | Notification manager.                                                |
| [which-key.nvim](https://github.com/folke/which-key.nvim)                            | Keymap discovery popup.                                              |
| [smear-cursor.nvim](https://github.com/sphamba/smear-cursor.nvim)                    | Animated cursor smear effect.                                        |
| [render-markdown.nvim](https://github.com/MeanderingProgrammer/render-markdown.nvim) | Inline markdown preview (headings, tables, code blocks, checkboxes). |
| [nvim-autopairs](https://github.com/windwp/nvim-autopairs)                           | Auto-close brackets, quotes.                                         |

### Diagnostics & TODOs

| Plugin                                                            | What it does                                                  |
| ----------------------------------------------------------------- | ------------------------------------------------------------- |
| [trouble.nvim](https://github.com/folke/trouble.nvim)             | Pretty list for diagnostics, LSP references, quickfix, TODOs. |
| [todo-comments.nvim](https://github.com/folke/todo-comments.nvim) | Highlight and navigate TODO/FIX/HACK/NOTE comments.           |

### Terminal & sessions

| Plugin                                                        | What it does                           |
| ------------------------------------------------------------- | -------------------------------------- |
| [toggleterm.nvim](https://github.com/akinsho/toggleterm.nvim) | Floating/vertical/horizontal terminal. |
| [persistence.nvim](https://github.com/folke/persistence.nvim) | Save/restore session per branch.       |

### AI

| Plugin                                                                | What it does                                                                                                              |
| --------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------- |
| [codecompanion.nvim](https://github.com/olimorris/codecompanion.nvim) | AI chat, inline edits, code actions. Adapter auto-detects OpenCode, OpenAI, Anthropic, Gemini, Ollama, or Copilot.        |
| [minuet-ai.nvim](https://github.com/milanglacier/minuet-ai.nvim)      | AI inline completions. Provider auto-detects Ollama, OpenAI, Anthropic, Gemini. Default: local Ollama `qwen2.5-coder:7b`. |

## Keymaps

Leader is `<Space>`. Open `:Helpme` or press `<leader>?` for the full cheatsheet.

### Quick reference

| Key                                     | Action                              |
| --------------------------------------- | ----------------------------------- |
| `<leader>w` / `<leader>q` / `<leader>x` | write / quit / write+quit           |
| `<leader>ff`                            | find files (fzf)                    |
| `<leader>fg`                            | live grep project (fzf)             |
| `<leader>fb`                            | open buffers (fzf)                  |
| `<leader>e`                             | toggle Neo-tree sidebar             |
| `-`                                     | Oil parent directory                |
| `<leader>tt`                            | floating terminal                   |
| `<leader>dd`                            | diagnostics (Trouble)               |
| `<leader>ca`                            | LSP code actions                    |
| `<leader>cf`                            | format buffer                       |
| `gd` / `gr`                             | go to definition / references (fzf) |
| `<leader>hs` / `<leader>hr`             | stage / reset hunk                  |
| `<leader>ac`                            | AI chat toggle                      |
| `<leader>aa`                            | AI actions                          |
| `<leader>as`                            | toggle Minuet inline completions    |
| `<leader>ao`                            | opencode in floating terminal       |
| `<leader>mp`                            | toggle markdown inline preview      |
| `<leader>tc`                            | toggle treesitter context           |
| `<leader>tw` / `<leader>ts`             | toggle wrap / spell                 |
| `<leader>ps` / `<leader>pl`             | restore session / last session      |
| `<leader>?`                             | open this help                      |

## Theme

Custom theme system via `lua/theme.lua`. Reads active theme from `$XDG_DATA_HOME/dotfiles/active-theme` (set by `dots theme set`). Falls back to catppuccin-mocha. Theme files live in `~/dotfiles/themes/<name>/nvim.lua`.

Available themes: catppuccin-mocha, catppuccin-latte, tokyo-night, rose-pine, gruvbox, kanagawa, nord.

Switch: `dots theme set <name>`.

## LSP servers

Managed by mason. Auto-installed on first launch:

| Language       | Server         |
| -------------- | -------------- |
| Lua            | lua_ls         |
| Python         | pyright + ruff |
| Rust           | rust_analyzer  |
| TypeScript/TSX | ts_ls          |
| Bash           | bashls         |
| Markdown       | marksman       |
| JSON           | jsonls         |
| YAML           | yamlls         |
| HTML/CSS       | html, cssls    |
| Go             | gopls          |

## Formatters (conform)

| Filetype  | Formatter                     |
| --------- | ----------------------------- |
| Lua       | stylua                        |
| Python    | ruff_format                   |
| Rust      | rustfmt                       |
| Go        | goimports, gofmt              |
| JS/TS/TSX | prettierd → prettier fallback |
| All       | trim_whitespace               |

## Requirements

- Neovim 0.12+
- `git`, `fzf`, `cargo` (for blink.cmp fuzzy matcher)
- `node` (for markdown-preview, prettierd)
- `ruff` (Python linter/formatter)
- Nerd Font (for icons in statusline, bufferline, neo-tree)

## Environment overrides

| Variable            | Effect                                                        |
| ------------------- | ------------------------------------------------------------- |
| `OPENAI_API_KEY`    | CodeCompanion + Minuet use OpenAI                             |
| `ANTHROPIC_API_KEY` | CodeCompanion + Minuet use Anthropic                          |
| `GEMINI_API_KEY`    | CodeCompanion + Minuet use Gemini                             |
| `OLLAMA_HOST`       | CodeCompanion + Minuet use Ollama (default `localhost:11434`) |
| `MINUET_MODEL`      | Minuet model (default `qwen2.5-coder:7b`)                     |
| `MINUET_PROVIDER`   | Minuet provider override                                      |
| `MINUET_ENDPOINT`   | Minuet API endpoint override                                  |
