# Tmux Cheatsheet

Config in `~/.tmux.conf` (omarchy-inspired). **Prefix rebound from `C-b` → `C-a`.**

## Prefix

| Bind         | Action                                       |
| ------------ | -------------------------------------------- |
| `Ctrl-a`     | Prefix (replaces default `C-b`)              |
| `Ctrl-a C-a` | Send literal `C-a` (for apps inside tmux)    |
| `prefix + r` | Reload `~/.tmux.conf` without restarting     |

## Sessions

| Cmd / Bind                    | Action                            |
| ----------------------------- | --------------------------------- |
| `tmux`                        | New session                       |
| `tmux new -s <name>`          | New named session                 |
| `tmux ls`                     | List sessions                     |
| `tmux attach -t <name>`       | Reattach to session               |
| `tmux kill-session -t <name>` | Kill session                      |
| `tmux rename-session -t a b`  | Rename `a` → `b`                  |
| `prefix + d`                  | Detach from session               |
| `prefix + $`                  | Rename current session            |
| `prefix + s`                  | Interactive session picker        |

## Windows

| Bind                  | Action                                |
| --------------------- | ------------------------------------- |
| `prefix + c`          | New window (in current `$PWD`)        |
| `prefix + ,`          | Rename window                         |
| `prefix + n` / `p`    | Next / previous window                |
| `prefix + 0..9`       | Jump to window `n`                    |
| `prefix + &`          | Kill window                           |
| `Alt-1..5`            | Switch window 1..5 (**no prefix**)    |
| `renumber-windows on` | Closing a window shifts the rest down |

## Panes (splits)

| Bind                | Action                                |
| ------------------- | ------------------------------------- |
| `prefix + \|`       | Vertical split (same `$PWD`)          |
| `prefix + -`        | Horizontal split (same `$PWD`)        |
| `prefix + h/j/k/l`  | Focus pane (vim-style)                |
| `prefix + H/J/K/L`  | Resize pane by 5 cells (repeatable)   |
| `prefix + x`        | Kill pane                             |
| `prefix + z`        | Zoom / unzoom pane                    |
| `prefix + Space`    | Cycle layouts (even-h, tiled, …)      |
| `prefix + {` / `}`  | Swap pane with neighbour              |
| `prefix + !`        | Break pane into its own window        |

## Copy mode (vi)

| Bind         | Action                              |
| ------------ | ----------------------------------- |
| `prefix + [` | Enter copy mode                     |
| `q` / `Esc`  | Exit copy mode                      |
| `v`          | Begin selection (character)         |
| `V`          | Select line                         |
| `y`          | Yank → wl-copy (system clipboard)   |
| `/` / `?`    | Search forward / backward           |
| `n` / `N`    | Next / previous match               |
| `g` / `G`    | Top / bottom                        |
| `h j k l`    | Movement                            |
| `Ctrl-d/u`   | Half-page down / up                 |

## Plugins (tpm)

| Plugin               | What it does                              |
| -------------------- | ----------------------------------------- |
| `tpm`                | Plugin manager                            |
| `tmux-resurrect`     | `prefix + Ctrl-s` save / `Ctrl-r` restore |
| `tmux-continuum`     | Autosave every 15 min + restore on start  |
| `tmux-yank`          | `y` in copy-mode → wl-copy                |
| `vim-tmux-navigator` | `Ctrl-h/j/k/l` across panes + nvim splits |

## Tpm commands

| Bind             | Action                     |
| ---------------- | -------------------------- |
| `prefix + I`     | Install plugins            |
| `prefix + U`     | Update plugins             |
| `prefix + Alt-u` | Remove plugins not in list |

## Active settings

| Setting                              | Why                                |
| ------------------------------------ | ---------------------------------- |
| `default-terminal "tmux-256color"`   | True-color + italics supported     |
| `escape-time 10`                     | No delay on ESC (nvim happy)       |
| `focus-events on`                    | nvim `FocusGained/Lost` work       |
| `history-limit 50000`                | Long scrollback                    |
| `mouse on`                           | Scroll + click panes               |
| `base-index 1` / `pane-base-index 1` | Windows/panes start at 1           |
| `renumber-windows on`                | No gaps when closing windows       |
| `set-clipboard on`                   | OSC 52 — copy via terminal escape  |

## Resurrect / continuum

Saved in `~/.tmux/resurrect/`. Layout + names + nvim sessions preserved.

| Bind              | Action                   |
| ----------------- | ------------------------ |
| `prefix + Ctrl-s` | Save session manually    |
| `prefix + Ctrl-r` | Restore session          |

## Workflow examples

```bash
# Per-project session
tmux new -s dotfiles
# detach: prefix + d
tmux attach -t dotfiles

# List and pick
tmux ls
tmux attach -t <name>

# Kill everything (careful — loses resurrect state if not saved)
tmux kill-server
```

## Tips

| Tip                                       | Why it helps                          |
| ----------------------------------------- | ------------------------------------- |
| Per-project sessions (`-s name`)          | Fast context switching                |
| Vim-style `h/j/k/l` in copy + panes       | Unified muscle memory                 |
| `Alt-1..5` (no prefix) for window switch  | Less `Ctrl-a` mashing                 |
| Continuum auto-save + restore             | Reboot doesn't lose layout            |
| `set-clipboard on` + `tmux-yank`          | `y` in copy mode → system clipboard   |
