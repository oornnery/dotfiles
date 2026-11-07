# Neovim setup

Personal Neovim configuration. Modular, lazy-loaded, tuned for daily development on this machine (VAIO, Arch). Everything is a file you can read — no generated config, no framework.

## Why this setup

- **lazy.nvim** specs: one file per area (`lua/plugins/*.lua`), each plugin lazy-loaded by keymap, event or command — startup stays fast.
- **Pure Lua where it matters**: statusline and theme are hand-written (`lua/statusline.lua`, `lua/theme.lua`), no lualine/colorscheme dependency.
- **Focused AI stack**: OpenCode, Claude Code and Codex handle agent work; Codex (ChatGPT subscription) provides inline completion.
- **Single source of truth for keys**: `docs/cheatsheet.md` — open it inside nvim with `<leader>?` / `:Helpme`.

## Structure

```text
~/.config/nvim/
├── init.lua                  entry point (providers, netrw off, load order)
├── README.md                 this file
├── lazy-lock.json            pinned plugin versions (committed)
├── colors/
│   └── dotfiles.lua          colorscheme shim → re-applies the theme
├── docs/
│   └── cheatsheet.md         all keybindings (open with <leader>? / :Helpme)
├── lua/
│   ├── theme.lua             custom theme loader (dots theme system)
│   ├── statusline.lua        pure Lua global statusline
│   ├── cheatsheet.lua        :Helpme / :Cheatsheet / <leader>?
│   ├── config/
│   │   ├── options.lua       vim.opt settings
│   │   ├── lazy.lua          lazy.nvim bootstrap + global options
│   │   ├── autocmds.lua      autocmds + user commands (:Root, :Term, …)
│   │   └── keymaps.lua       base keymaps (plugin maps live in specs)
│   └── plugins/              one spec file per area (see below)
```

## First run

For MobaXterm/SSH compatibility use `DOTFILES_TERMINAL=basic nvim`. For an offline,
no-plugin baseline add `DOTFILES_NVIM_PLUGINS=0`. See the
[terminal guide](../../../docs/applications/02-neovim.md) for behavior and checks.

1. Install [Neovim 0.12+](https://github.com/neovim/neovim/releases) and a Nerd Font.
2. Start `nvim` — lazy.nvim bootstraps itself, plugins install, treesitter parsers compile, mason installs the LSP servers (`lua_ls`, `rust_analyzer`, `ts_ls`, `pyright`, `ruff`, `bashls`, `marksman`).
3. Optional but recommended: `fzf` binary (fzf-lua), `opencode` CLI (AI pairing), `codex` CLI logged in with ChatGPT (inline completion).
4. Press `<leader>?` to read the cheatsheet.

## Plugin manager

[lazy.nvim](https://github.com/folke/lazy.nvim) — auto-bootstrapped on first launch (stable branch). Plugins are declared in `lua/plugins/*.lua` and lazy-loaded by event, command or keymap. `lazy-lock.json` pins every plugin; commits it after `:Lazy update`. Background update check runs silently (`checker`), so an outdated plugin never nags you.

Adding a plugin = adding a table in the right spec file (or a new file in `lua/plugins/`). Example:

```lua
-- lua/plugins/example.lua
return {
  { "author/repo", event = "VeryLazy", opts = {}, keys = { ... } },
}
```

## Plugins — what, how, why

### Completion & LSP

| Plugin                                                                       | What it does                                                                              |
| ---------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------- |
| [blink.cmp](https://github.com/saghen/blink.cmp)                             | Completion engine with Rust fuzzy matcher. `version = "1.*"` → prebuilt binary, no cargo. |
| [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)                   | LSP server configs via the nvim 0.11+ `vim.lsp.config()` / `vim.lsp.enable()` API.        |
| [mason.nvim](https://github.com/williamboman/mason.nvim)                     | Install LSP servers, formatters, linters (`:Mason`).                                      |
| [mason-lspconfig.nvim](https://github.com/williamboman/mason-lspconfig.nvim) | Bridge mason → LSP config; auto-installs `ensure_installed` servers on first launch.      |
| [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)        | Syntax highlighting. Branch `main` (new API, nvim 0.12+), `build = ":TSUpdate"`.          |
| [conform.nvim](https://github.com/stevearc/conform.nvim)                     | Format on save (`format_on_save`), per-filetype formatters.                               |
| [lazydev.nvim](https://github.com/folke/lazydev.nvim)                        | Lua LSP completions for nvim config/plugin development (lua filetype only).               |
| [friendly-snippets](https://github.com/rafamadriz/friendly-snippets)         | Snippet source for blink.cmp.                                                             |

Why: blink over nvim-cmp because it is fast, single-file-config and maintains its own LSP capabilities. The old `cmp.*` APIs that Noice documents are still bridged for backwards compat.

How: completion opens automatically on insert (`menu.auto_show`), ghost text on, `super-tab` preset (see Keymaps). Signature help via LSP. AI ghost text comes from codex-complete, outside Blink (see AI).

### AI

| Plugin                                                                  | What it does                                                                                                         |
| ----------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------- |
| [codex-complete.nvim](https://github.com/joegoggin/codex-complete.nvim) | Inline ghost-text completion through `codex app-server`, billed to the ChatGPT subscription from `codex login`.      |
| [opencode.nvim](https://github.com/nickjvandyke/opencode.nvim)          | Native pairing with the OpenCode CLI: ask with `@this` context, built-in prompts, accept/reject edits via diffpatch. |
| [sidekick.nvim](https://github.com/folke/sidekick.nvim)                 | Runs the Claude Code and Codex CLIs in a split and sends editor context into them.                                   |

No API keys: every AI path goes through a vendor CLI and its own login.
**OpenCode**, **Claude Code** and **Codex** own chat, agent actions, edits and
review; **codex-complete** only writes ghost text.

Completion uses `gpt-5.6-luna` at `low` reasoning, the fastest model the
subscription exposes. Expect roughly 5–9 s per suggestion (the first one also
starts the app server), so it fits "pause and accept" rather than per-keystroke
typing. Requests fire 300 ms after typing stops, each keystroke cancels the
previous one, and they count against the Codex subscription limits. Threads are
ephemeral, read-only, with network off. Sensitive files (`.env`, keys,
credentials) are never sent. Claude's subscription cannot drive completion:
Anthropic only allows it inside the official Claude Code client.

sidekick.nvim: `<leader>ac` Claude, `<leader>ax` Codex, `<leader>at` send
`{this}`, `<leader>aF` send file, `<leader>ad` detach, `<C-.>` focus.

opencode.nvim needs `opencode` on PATH; first use
spawns `opencode --port` in a vsplit; proposed edits open in a diffpatch tab
(`da`/`dr` to accept/reject).

### Navigation & search

| Plugin                                                                                | What it does                                                                     |
| ------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------- |
| [fzf-lua](https://github.com/ibhagwan/fzf-lua)                                        | Fuzzy finder (files, grep, buffers, symbols, keymaps, help). Preset `fzf-vim`.   |
| [flash.nvim](https://github.com/folke/flash.nvim)                                     | Jump to any visible word with labels (`s`), treesitter jump (`S`).               |
| [mini.surround](https://github.com/echasnovski/mini.surround)                         | Add/delete/replace surrounding pairs (`gsa`, `gsd`, `gsr`).                      |
| [mini.ai](https://github.com/echasnovski/mini.ai)                                     | Better text objects (`af`/`if`, `aa`/`ia`, …).                                   |
| [indent-blankline.nvim](https://github.com/lukas-reineke/indent-blankline.nvim)       | Indentation guides + scope.                                                      |
| [nvim-treesitter-context](https://github.com/nvim-treesitter/nvim-treesitter-context) | Sticky header showing current function/class context (toggle with `<leader>tc`). |

Why: fzf over telescope because the `fzf` binary is already a dotfiles dependency and fzf-lua keeps a single tool for everything (buffers, grep, help, keymaps). Flash replaces the modal `s`-jump flow with label jumping.

### File explorers

| Plugin                                                          | What it does                                                                                             |
| --------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------- |
| [neo-tree.nvim](https://github.com/nvim-neo-tree/neo-tree.nvim) | Sidebar file tree (branch `v3.x`). Sources: filesystem, buffers, git.                                    |
| [oil.nvim](https://github.com/stevearc/oil.nvim)                | Edit directories as buffers; `-` opens the parent. Default file explorer (netrw is disabled on purpose). |

Why: neo-tree when you want a persistent tree with git status; oil when you want to manipulate files like text (rename/delete/move with undo). oil replaces netrw so `-` behaves as expected everywhere.

### Git

| Plugin                                                      | What it does                                                             |
| ----------------------------------------------------------- | ------------------------------------------------------------------------ |
| [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim) | Git hunks in the sign column, hunk stage/reset/preview, blame, diffthis. |

### UI

| Plugin                                                                               | What it does                                                          |
| ------------------------------------------------------------------------------------ | --------------------------------------------------------------------- |
| [bufferline.nvim](https://github.com/akinsho/bufferline.nvim)                        | Top buffer tabs with diagnostics counts and offsets for explorer/oil. |
| [noice.nvim](https://github.com/folke/noice.nvim)                                    | Modern cmdline popup, message history, LSP docs.                      |
| [nvim-notify](https://github.com/rcarriga/nvim-notify)                               | Notification manager (noice renders on top).                          |
| [which-key.nvim](https://github.com/folke/which-key.nvim)                            | Keymap discovery popup on `<leader>` prefix.                          |
| [smear-cursor.nvim](https://github.com/sphamba/smear-cursor.nvim)                    | Animated cursor. Pure eye-candy, loaded at startup (`lazy = false`).  |
| [render-markdown.nvim](https://github.com/MeanderingProgrammer/render-markdown.nvim) | Inline markdown preview (headings, tables, code, checkboxes).         |
| [nvim-autopairs](https://github.com/windwp/nvim-autopairs)                           | Auto-close brackets/quotes (treesitter-aware).                        |

### Diagnostics & TODOs

| Plugin                                                            | What it does                                                  |
| ----------------------------------------------------------------- | ------------------------------------------------------------- |
| [trouble.nvim](https://github.com/folke/trouble.nvim)             | Pretty list for diagnostics, symbols, LSP refs, quickfix.     |
| [todo-comments.nvim](https://github.com/folke/todo-comments.nvim) | Highlight TODO/FIX/HACK/NOTE/PERF/TEST comments + navigation. |

### Terminal & sessions

| Plugin                                                        | What it does                                         |
| ------------------------------------------------------------- | ---------------------------------------------------- |
| [toggleterm.nvim](https://github.com/akinsho/toggleterm.nvim) | Floating, vertical, and horizontal terminals.        |
| [persistence.nvim](https://github.com/folke/persistence.nvim) | Per-project sessions (`<leader>ps`/`pl`/`pS`/`pd`).  |

## Keymaps

Leader is `<Space>` (localleader `\`). This is the full list; the same content lives in `docs/cheatsheet.md` (`<leader>?` / `:Helpme`).

### Core & windows

| Key                         | Modes | Action                              |
| --------------------------- | ----- | ----------------------------------- |
| `<leader>w` / `q` / `x`     | n     | write / quit / write+quit           |
| `<leader>bb` / `<leader>bd` | n     | switch / delete buffer              |
| `[b` / `]b`                 | n     | previous / next buffer              |
| `<S-h>` / `<S-l>`           | n     | previous / next bufferline tab      |
| `<leader>bp` / `<leader>bP` | n     | pick buffer / pick buffer to close  |
| `<leader>bo` / `br` / `bl`  | n     | close others / right / left buffers |
| `<C-h/j/k/l>`               | n     | move to window                      |
| `<leader>sv` / `sh`         | n     | vertical / horizontal split         |
| `<leader>=`                 | n     | equalize windows                    |
| `<Esc><Esc>`                | n     | clear search highlight              |
| `<Esc><Esc>`                | t     | terminal → normal mode              |
| `<leader>tw` / `<leader>ts` | n     | toggle wrap / spell                 |
| `<` / `>`                   | x     | indent and reselect                 |

### Find & files (fzf-lua)

| Key                        | Action                             |
| -------------------------- | ---------------------------------- |
| `<leader>ff` / `fg` / `fb` | files / live grep / buffers        |
| `<leader>fo` / `fh` / `fk` | recent files / help tags / keymaps |
| `<leader>fr`               | resume last picker                 |
| `<leader>fs` / `fS`        | document / workspace symbols       |
| `<leader>fc`               | command history                    |

### Explorers

| Key                             | Action                               |
| ------------------------------- | ------------------------------------ |
| `<leader>e` / `E`               | Neo-tree sidebar / float reveal      |
| `<leader>ge` / `be`             | Neo-tree git status / buffers source |
| `-` / `<leader>o` / `<leader>O` | Oil parent / dir buffer / float      |

### LSP & diagnostics

Only when a server is attached. (`gd`/`gr` are plain LSP, not fzf.)

| Key                                      | Action                                                     |
| ---------------------------------------- | ---------------------------------------------------------- |
| `gd` / `gr` / `gI` / `gy`                | definition / references / implementation / type definition |
| `K`                                      | hover                                                      |
| `<leader>ca`                             | code actions                                               |
| `<leader>crn`                            | rename                                                     |
| `<leader>cf`                             | format (conform, falls back to LSP)                        |
| `[d` / `]d`                              | previous / next diagnostic                                 |
| `<leader>qf`                             | diagnostics → location list                                |
| `<leader>dd` / `dD` / `ds` / `dl` / `dq` | Trouble: diagnostics / buffer / symbols / refs / quickfix  |
| `]t` / `[t`                              | next / previous TODO comment                               |
| `<leader>dt` / `dT`                      | TODOs in Trouble / quickfix                                |

### Git hunks (gitsigns)

| Key                        | Action                                |
| -------------------------- | ------------------------------------- |
| `[c` / `]c`                | previous / next hunk                  |
| `<leader>hs` / `hr`        | stage / reset hunk (visual = range)   |
| `<leader>hS` / `hR`        | stage / reset buffer                  |
| `<leader>hp` / `hb` / `hd` | preview hunk / blame line / diff this |
| `ih`                       | select hunk (operator/visual)         |

### Movement & text objects

| Key                   | Action                           |
| --------------------- | -------------------------------- |
| `s` / `S`             | flash jump / flash treesitter    |
| `r` (o) / `R` (o,x)   | flash remote / treesitter search |
| `<C-s>` (c)           | toggle flash search              |
| `gsa` / `gsd` / `gsr` | surround add / delete / replace  |
| `af`/`if`, `aa`/`ia`  | function / argument text objects |

### Completion (blink.cmp)

| Key                 | Action                                         |
| ------------------- | ---------------------------------------------- |
| `<Tab>` / `<S-Tab>` | next / previous item (super-tab preset)        |
| `<C-space>`         | show completion / docs                         |
| `<C-e>`             | hide menu                                      |

### Markdown

| Key          | Action                                |
| ------------ | ------------------------------------- |
| `<leader>mp` | toggle render-markdown inline preview |

### AI

| Key                    | Action                                         |
| ---------------------- | ---------------------------------------------- |
| `<leader>aa` (n,x)     | ask OpenCode about cursor/selection (`@this`)  |
| `<leader>ap` (n,x)     | OpenCode prompt/command/server picker          |
| `<leader>ac` / `ax`    | sidekick: Claude Code / Codex CLI              |
| `<leader>at` / `aF`    | sidekick: send `{this}` / file                 |
| `<leader>ad` / `<C-.>` | sidekick: detach / focus                       |
| `<C-l>` / `<M-s>` (i)  | Codex: accept suggestion / request one now     |
| `<leader>as`           | Codex: toggle suggestions                      |
| `<leader>aM` / `aR`    | Codex: choose model / reasoning effort         |
| `<leader>ai` / `<M-;>` | Codex: code from comment under cursor / accept |

### Terminal, UI & sessions

| Key                                             | Action                                                |
| ----------------------------------------------- | ----------------------------------------------------- |
| `<leader>tt` / `tv` / `th`                      | terminal float / vertical / horizontal                |
| `<C-\>`                                         | toggle last terminal                                  |
| `<leader>nn` / `nl` / `ne` / `nd` / `np` / `nf` | Noice history / last / errors / dismiss / pick / find |
| `<leader>nD` / `nE`                             | disable / enable Noice                                |
| `<S-Enter>` (c)                                 | redirect command output to popup                      |
| `<C-f>` / `<C-b>`                               | scroll hover/signature docs                           |
| `<leader>ps` / `pS` / `pl` / `pd`               | session restore / pick / last / stop                  |
| `<leader>?`                                     | open this help                                        |

## User commands

| Command                       | What it does                                                                                      |
| ----------------------------- | ------------------------------------------------------------------------------------------------- |
| `:Helpme` / `:Cheatsheet`     | open the cheatsheet in a new tab                                                                  |
| `:Root`                       | cd to project root (`.git`, `pyproject.toml`, `package.json`, `Cargo.toml`, `go.mod`, `Makefile`) |
| `:Term`                       | bottom split terminal (14 lines)                                                                  |
| `:TrimWhitespace`             | strip trailing whitespace (skip markdown/text/gitcommit)                                          |
| `:MkSession` / `:LoadSession` | save / restore `.session.vim` in the project                                                      |
| `:Mason`                      | manage LSP servers/formatters                                                                     |
| `:Lazy`                       | plugin manager UI                                                                                 |
| `:checkhealth codex_complete` | Codex completion diagnostics                                                                      |
| `:TSUpdate`                   | rebuild treesitter parsers (see Troubleshooting)                                                  |

## Theme

Custom theme system (`lua/theme.lua`) — no colorscheme plugin. It reads the active theme from `$XDG_DATA_HOME/dotfiles/active-theme` (written by `dots theme set`) and loads `~/dotfiles/themes/<name>/nvim.lua`. Highlights (~180 groups) are applied manually for editor + plugins (GitSigns, NeoTree, BufferLine, WhichKey, Noice, Notify, FzfLua, BlinkCmp, Flash, Trouble, RenderMarkdown…) and re-applied on every `ColorScheme` event. Falls back to a built-in catppuccin-mocha spec if the file is missing.

Available themes: `catppuccin-mocha` (default), `catppuccin-latte`, `tokyo-night`, `rose-pine`, `gruvbox`, `kanagawa`, `nord`.

Switch with `dots theme set <name>` (from the dotfiles repo) — no nvim restart needed.

## LSP servers

Managed by mason, auto-installed on first launch, enabled via `vim.lsp.enable`:

| Language       | Server        | Notes                                                                             |
| -------------- | ------------- | --------------------------------------------------------------------------------- |
| Lua            | lua_ls        | LuaJIT runtime, nvim globals                                                      |
| Python         | ty + ruff     | ty types/hover/goto/completion; ruff only for diagnostics (hover/format disabled) |
| Rust           | rust_analyzer |                                                                                   |
| TypeScript/TSX | ts_ls         |                                                                                   |
| Bash           | bashls        |                                                                                   |
| Markdown       | marksman      |                                                                                   |

Python buffers also get `<localleader>` (`\`) keys that run through uv in
toggleterm #9: `r` run file, `t` / `T` pytest file / project, `c` `ty check` +
`ruff check` for the whole project. `i` opens the REPL in terminal #8 and `s`
sends the line or visual selection to it (bracketed paste, so indented blocks
survive the 3.13+ REPL).

To add more: install via `:Mason`, then add a `vim.lsp.config()` block + `vim.lsp.enable()` in `lua/plugins/lsp.lua`.

## Formatters (conform)

Format on save (`format_on_save`, 500 ms debounce, LSP fallback):

| Filetype  | Formatter                          |
| --------- | ---------------------------------- |
| Lua       | stylua                             |
| Python    | ruff_organize_imports, ruff_format |
| Rust      | rustfmt                            |
| Go        | goimports, gofmt                   |
| JS/TS/TSX | prettierd → prettier fallback      |
| All       | trim_whitespace                    |

## Environment overrides

| Variable                                                                      | Effect                                                                                 |
| ----------------------------------------------------------------------------- | -------------------------------------------------------------------------------------- |
| `DOTFILES_DIR`                                                                | where theme files are read from (default `~/dotfiles`)                                 |

## Requirements

- **Neovim 0.12+** (blink.cmp and the new treesitter API require it)
- `git`, `fzf`, a Nerd Font (icons)
- `opencode` CLI — optional, powers opencode.nvim
- `codex` CLI logged in with ChatGPT — inline completion and sidekick.nvim
- `claude` CLI — optional, used by sidekick.nvim
- `uv` — Python run/test keys
- `node` — only needed for prettierd (JS/TS formatting)
- `cargo` — only if you switch blink.cmp away from `version = "1.*"` to build the fuzzy matcher from source
- `gcc`/`cc` — treesitter parser compilation

## Troubleshooting

### Treesitter "Query error: Invalid node type …" (e.g. `"tab"`)

You get `noice.nvim xN: Query error … Invalid node type "tab"` (or similar) at startup. Cause: nvim-treesitter is on branch `main` and updates its queries faster than the compiled parsers in `~/.local/share/nvim/site/parser/` — the query expects nodes the installed `.so` doesn't have yet. The `build = ":TSUpdate"` hook can die silently mid-update.

Fix:

```text
:TSUpdate
```

If it persists for one parser (e.g. `vim`), force it: `:TSInstall! vim`. The query error is the symptom; the parser and the query must come from the same nvim-treesitter commit.

### blink.cmp fuzzy matcher not working

`version = "1.*"` downloads prebuilt binaries — if the install is broken, remove and re-sync:

```bash
rm -rf ~/.local/share/nvim/lazy/blink.cmp
nvim   # then :Lazy sync
```

`fuzzy.implementation = "prefer_rust_with_warning"` falls back to Lua with a warning if the binary is missing. Do not mix `version = "1.*"` with `build = "cargo build --release"`.

### LSP server not starting

Check `:Mason` (installed?), `:LspInfo`, and `:checkhealth lsp`. Servers are only enabled if listed in `vim.lsp.enable(...)` in `lua/plugins/lsp.lua`.

### Plugin update broke something

`lazy-lock.json` is committed — `git checkout lazy-lock.json && :Lazy restore` rewinds to the last known-good set.
