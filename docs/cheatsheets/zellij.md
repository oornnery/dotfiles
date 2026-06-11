# Zellij Cheatsheet

Config in `~/.config/zellij/config.kdl`. **Vim-flavored, Catppuccin Mocha.**

## Prefix / Modes

Zellij is mode-based. Most keys pass through in `normal` mode.

| Bind     | Action                          |
| -------- | ------------------------------- |
| `Ctrl+b` | Enter **pane** mode             |
| `Ctrl+t` | Enter **tab** mode              |
| `Ctrl+r` | Enter **resize** mode           |
| `Ctrl+m` | Enter **move** mode             |
| `Ctrl+s` | Enter **scroll** mode           |
| `Ctrl+o` | Enter **session** mode          |
| `Ctrl+n` | Return to **normal** mode       |
| `Ctrl+g` | Lock session                    |

## Pane Mode (`Ctrl+b`)

| Bind     | Action                                |
| -------- | ------------------------------------- |
| `h/j/k/l`| Move focus left/down/up/right         |
| `H/J/K/L`| Move focus (alternative)              |
| `n`      | New pane (default split)              |
| `d`      | New pane (horizontal split)           |
| `r`      | New pane (vertical split)             |
| `s`      | New pane (stacked)                    |
| `x`      | Close current pane                    |
| `p`      | Switch focus to next pane             |
| `e`      | Toggle pane embed/floating            |
| `f`      | Toggle fullscreen                     |
| `z`      | Toggle pane frames                    |
| `c`      | Rename pane                           |
| `Ctrl+b` | Return to **normal** mode             |

## Tab Mode (`Ctrl+t`)

| Bind     | Action                                |
| -------- | ------------------------------------- |
| `h/l`    | Previous / next tab                   |
| `1..9`   | Jump to tab 1-9                       |
| `n`      | New tab                               |
| `x`      | Close current tab                     |
| `r`      | Rename tab                            |
| `tab`    | Toggle previous/next tab              |
| `Ctrl+t` | Return to **normal** mode             |

## Resize Mode (`Ctrl+r`)

| Bind     | Action                                |
| -------- | ------------------------------------- |
| `h/j/k/l`| Increase left/down/up/right           |
| `H/J/K/L`| Decrease left/down/up/right           |
| `+` / `-`| Increase / decrease overall size      |
| `Ctrl+r` | Return to **normal** mode             |

## Move Mode (`Ctrl+m`)

| Bind     | Action                                |
| -------- | ------------------------------------- |
| `h/j/k/l`| Move pane left/down/up/right          |
| `tab`    | Cycle pane position                   |
| `Ctrl+m` | Return to **normal** mode             |

## Scroll Mode (`Ctrl+s`)

| Bind     | Action                                |
| -------- | ------------------------------------- |
| `j/k`    | Scroll down / up (line by line)       |
| `h/l`    | Page up / down                        |
| `Ctrl+u/d`| Half-page up / down                  |
| `g/G`    | Scroll to top / bottom                |
| `Ctrl+s` | Return to **normal** mode             |

## Session Mode (`Ctrl+o`)

| Bind     | Action                                |
| -------- | ------------------------------------- |
| `d`      | Detach from session                   |
| `Ctrl+o` | Return to **normal** mode             |

## CLI Commands

| Command                    | Action                          |
| -------------------------- | ------------------------------- |
| `zellij`                   | Start new session or attach     |
| `zellij attach <name>`     | Attach to named session         |
| `zellij ls`                | List active sessions            |
| `zellij kill-session`      | Kill current session            |
| `zellij setup --check`     | Verify configuration            |

## Active Settings

| Setting            | Value             | Why                                |
| ------------------ | ----------------- | ---------------------------------- |
| `theme`            | `catppuccin-mocha`| Consistent color palette           |
| `pane_frames`      | `false`           | Cleaner look, no borders           |
| `simplified_ui`    | `true`            | Avoids nerdfont `>>>` rendering    |
| `default_shell`    | `zsh`             | Consistent shell environment       |
| `scroll_buffer_size`| `10000`          | Long scrollback history            |
