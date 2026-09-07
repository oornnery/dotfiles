# Zsh Cheatsheet

Zsh + Oh-My-Zsh + Starship prompt. Config in `~/.zshrc`, functions in
`~/.zsh_functions`. Aliases below are the ones defined in this dotfiles repo.

## Startup and maintenance

The `zsh` Stow package owns `.zshrc` and `.zshenv`. Open a new terminal after
changes; repeatedly sourcing `.zshrc` can register duplicate plugin hooks.

- PATH entries are deduplicated while preserving their first occurrence.
- OpenCode completions are cached in `~/.cache/zsh/opencode-completion.zsh`
  (or `$XDG_CACHE_HOME/zsh`). Replacing the binary invalidates the cache.
  Run `opencode-completion-refresh` to rebuild manually. The first load after
  installation or upgrade still pays the generation cost.
- fnm, Atuin and mise generate their initialization code inside the deferred
  callback. direnv is registered synchronously for the first prompt.
- forgit installation belongs to `zsh/setup.sh`, not shell startup. An incomplete
  checkout is preserved and skipped until repaired; other Antigen bundles retain
  their existing installation behavior.
- Vi mode is displayed by the shell prompt. No mode label is sent as Zellij pane
  input.

Regression checks: `python3 scripts/test-zsh.py` and
`zsh -n zsh/.zshrc zsh/.zshenv`. The setup script backs up old compiled `.zwc`
files too, because a newer compiled file can override an edited startup file.

Keep any local migration backups outside this repository. Private
`~/.config/ai/env` is not managed by Stow. Vim, Neovim and Zsh links passed a
conflict-free Stow preview.

Performance measurements are machine-dependent: five warm non-TTY loads had
medians of 1.64 s for the new configuration and 1.65 s for the previous active
file, both inheriting the now-deduplicated PATH. That is not evidence of a
meaningful total speedup. A separate profile put cached OpenCode completion at
0.53 ms; Antigen and Vi-mode command discovery remain the main measured costs.
Non-TTY plugin loading emits ZLE warnings; the pseudo-terminal startup check
did not. These timings do not measure a complete interactive prompt render.

## File-op aliases (safe-by-default)

| Alias | Wraps   | Why                      |
| ----- | ------- | ------------------------ |
| `cp`  | `cp -i` | Prompts before overwrite |
| `mv`  | `mv -i` | Prompts before overwrite |
| `rm`  | `rm -i` | Prompts before deletion  |

> Bypass in scripts with `\rm`, `\cp`, `\mv` to skip the alias.

## Listing (eza)

| Alias | Expands to                      |
| ----- | ------------------------------- |
| `ls`  | `eza --icons=always`            |
| `ll`  | `eza -la --icons=always --git`  |
| `la`  | `eza -la --icons=always`        |
| `lsa` | `eza -la --icons=always`        |
| `lt`  | `eza --tree --icons=always`     |
| `lta` | `eza --tree -la --icons=always` |

## Modern tool replacements

| Alias  | Wraps                   | What                                  |
| ------ | ----------------------- | ------------------------------------- |
| `cat`  | `bat`                   | Syntax-highlighted cat                |
| `catp` | `bat -p`                | Plain (no decorations)                |
| `grep` | `grep --color=auto`     | Colored matches                       |
| `ff`   | `fzf --preview "bat …"` | Fuzzy file picker with preview        |
| `v`    | `nvim`                  | Editor (1 keystroke)                  |
| `g`    | `git`                   | Git (1 keystroke)                     |
| `lg`   | `lazygit`               | Git TUI                               |
| `ld`   | `lazydocker`            | Docker TUI                            |
| `py`   | `python`                | Python interpreter                    |

## Navigation

| Alias  | Means         |
| ------ | ------------- |
| `..`   | `cd ..`       |
| `...`  | `cd ../..`    |
| `....` | `cd ../../..` |

### zoxide (smart `cd` replacement)

| Command           | What                                              |
| ----------------- | ------------------------------------------------- |
| `z <fragment>`    | Jump to most-frecent dir matching fragment        |
| `zi <fragment>`   | Interactive picker with fzf                       |
| `z -`             | Previous directory (like `cd -`)                  |
| `z ..`            | Up one (works like cd)                            |

> Default still wired to `cd` if you prefer; `z` learns from your activity.

## Pacman shortcuts (Arch)

| Alias     | Expands to         | What                |
| --------- | ------------------ | ------------------- |
| `update`  | `sudo pacman -Syu` | Sync + upgrade      |
| `install` | `sudo pacman -S`   | Install package     |
| `remove`  | `sudo pacman -Rns` | Remove + deps       |
| `search`  | `pacman -Ss`       | Search packages     |
| `clean`   | `sudo pacman -Sc`  | Clean package cache |

> For AUR + native combined, use `paru` directly (no alias — keeps habits explicit).

## Config edits

| Alias           | Opens                      |
| --------------- | -------------------------- |
| `editz`         | `nvim ~/.zshrc`            |
| `edit-zenv`     | `nvim ~/.zshenv`           |
| `edit-zprofile` | `nvim ~/.zprofile`         |
| `edit-zlogin`   | `nvim ~/.zlogin`           |
| `reload`        | `exec zsh` (replace shell) |

## Line editor (Emacs-mode default, vi-mode active when ZVM loaded)

### Emacs-style (and vi `i` insert mode)

| Shortcut   | Action                      |
| ---------- | --------------------------- |
| `Ctrl + A` | Cursor to line start        |
| `Ctrl + E` | Cursor to line end          |
| `Ctrl + W` | Delete previous word        |
| `Ctrl + U` | Delete to line start        |
| `Ctrl + K` | Delete to line end          |
| `Ctrl + L` | Clear screen                |
| `Alt + .`  | Insert last arg of prev cmd |
| `!!`       | Re-run last command         |
| `!$`       | Last arg of previous cmd    |
| `!*`       | All args of previous cmd    |

### vi-mode (`zsh-vi-mode` plugin)

| Bind               | Action                                                |
| ------------------ | ----------------------------------------------------- |
| `Esc`              | Enter normal (command) mode                           |
| `i` / `a` / `o`    | Insert (before / after / new line) — back to insert   |
| `h` `j` `k` `l`    | Move (in normal mode)                                 |
| `w` `b` `e`        | Word forward / back / end                             |
| `0` / `$`          | Line start / end                                      |
| `dd` / `dw`        | Delete line / word                                    |
| `cw` / `cc`        | Change word / line                                    |
| `yy` / `p`         | Yank line / paste                                     |
| `u`                | Undo                                                  |
| `/text` then `n`   | Forward search in line history                        |
| `v`                | Open current command in `$EDITOR` (full vim power)    |

> `zsh-vi-mode` must be loaded **first** in the plugins array — it remaps
> keys that other plugins depend on. Indicator on the right of the prompt
> shows `I` (insert) / `N` (normal) — configurable in starship.

### History (zsh-history-substring-search)

| Bind      | Action                                              |
| --------- | --------------------------------------------------- |
| `↑` / `↓` | Substring-search history (filtered by current line) |
| `k` / `j` | Same, in vi normal mode                             |
| `Ctrl+R`  | Full fuzzy history search (fzf integration)         |

> Example: type `git` then press `↑` → only commands containing `git` cycle.

### atuin (optional, richer history)

Activated automatically if `atuin` binary exists (gated in `.zshrc`).

| Bind / Command      | What                                                 |
| ------------------- | ---------------------------------------------------- |
| `Ctrl+R` (atuin)    | Replaces the default reverse-search with TUI + stats |
| `atuin search`      | Search from any shell                                |
| `atuin import auto` | Import existing `.zhistory` into atuin's SQLite db   |
| `atuin login`       | Optional: sync history across machines via atuin.sh  |
| `atuin stats`       | Show your most-used commands, ratios, etc.           |

## Globbing extras

| Pattern   | Matches                      |
| --------- | ---------------------------- |
| `*.md`    | Files in current dir         |
| `**/*.md` | Recursive (no `find` needed) |
| `*(/)`    | Only directories             |
| `*(.)`    | Only regular files           |
| `*(L0)`   | Empty files                  |
| `*(mh-1)` | Modified in last hour        |

## Plugins active (Oh-My-Zsh)

| Plugin                         | What                                                                           |
| ------------------------------ | ------------------------------------------------------------------------------ |
| `zsh-vi-mode`                  | Modal vi editing in shell (`Esc` for normal mode)                              |
| `git` / `gh`                   | Aliases (`gst`, `gco`, `gp`, etc.) + GitHub CLI helpers                        |
| `sudo`                         | Double-`Esc` prepends `sudo` to current cmd                                    |
| `z`                            | Frecent-dir jumping (complements zoxide)                                       |
| `zsh-completions`              | Extra completion definitions catalog                                           |
| `zsh-autosuggestions`          | Fish-like ghost-text suggestion from history                                   |
| `fzf-tab`                      | Replaces tab completion UI with fzf picker (with previews)                     |
| `fast-syntax-highlighting`     | Syntax highlight as you type (replaces zsh-syntax-highlighting — 5-10× faster) |
| `zsh-history-substring-search` | `↑`/`↓` filter history by substring                                            |

## Functions (in `~/.zsh_functions`)

```bash
# List them:
awk '/^[a-zA-Z_][a-zA-Z0-9_-]*\(\)/' ~/.zsh_functions

# Or with descriptions (top-comment metadata):
dots-cheatsheet  # → "Shell functions" category
```

## Tips

| Tip                                              | Why it helps                            |
| ------------------------------------------------ | --------------------------------------- |
| `\rm` bypasses the `-i` alias                    | Use in scripts where prompts hang       |
| `Ctrl + R` (with fzf) > scrolling history        | Fuzzy match wins                        |
| `**/` glob beats nested `find`                   | Native zsh, faster, cleaner             |
| Aliases listed live: `dots-cheatsheet`           | One picker shows current state          |
| In vi-mode: hit `v` in normal → opens `$EDITOR`  | Edit a multi-line command in full nvim  |
| `fzf-tab` previews dirs with eza tree            | See structure before tab-completing     |
