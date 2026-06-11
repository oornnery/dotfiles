# Zellij

Terminal multiplexer replacing tmux. Configured for vim-flavored navigation,
Catppuccin Mocha theming, and simplified UI.

**Not auto-started.** Run `zellij` manually when you want a multiplexer session.

## Installation

Handled by the bootstrap:
```bash
./scripts/arch/arch.sh dev/zellij
```
This installs the `zellij` package and stows the dotfiles configuration.

## Keybindings

Zellij uses a **mode-based** system. The default mode is `normal`, where most
keystrokes pass directly to your terminal (e.g., vim, nvim, hx).

### Mode Switching (Normal Mode)

| Bind     | Action                          |
| -------- | ------------------------------- |
| `Ctrl+b` | Enter **pane** mode             |
| `Ctrl+t` | Enter **tab** mode              |
| `Ctrl+r` | Enter **resize** mode           |
| `Ctrl+m` | Enter **move** mode             |
| `Ctrl+s` | Enter **scroll** mode           |
| `Ctrl+n` | Return to **normal** mode       |
| `Ctrl+g` | Lock session                    |
| `Ctrl+o` | Enter **session** mode          |

### Pane Mode (`Ctrl+b`)

| Bind     | Action                          |
| -------- | ------------------------------- |
| `h/j/k/l`| Move focus left/down/up/right   |
| `n`      | New pane (default split)        |
| `d`      | New pane (horizontal split)     |
| `r`      | New pane (vertical split)       |
| `s`      | New pane (stacked)              |
| `x`      | Close current pane              |
| `p`      | Switch focus to next pane       |
| `e`      | Toggle pane embed/floating      |
| `f`      | Toggle fullscreen               |
| `z`      | Toggle pane frames              |
| `Ctrl+b` | Return to **normal** mode       |

### Tab Mode (`Ctrl+t`)

| Bind     | Action                          |
| -------- | ------------------------------- |
| `h/l`    | Previous / next tab             |
| `1..9`   | Jump to tab 1-9                 |
| `n`      | New tab                         |
| `x`      | Close current tab               |
| `Ctrl+t` | Return to **normal** mode       |

### Scroll Mode (`Ctrl+s`)

| Bind     | Action                          |
| -------- | ------------------------------- |
| `j/k`    | Scroll down / up (line by line) |
| `h/l`    | Page up / down                  |
| `g/G`    | Scroll to top / bottom          |
| `Ctrl+s` | Return to **normal** mode       |

## Theme

The configuration uses **Catppuccin Mocha** with a simplified UI to avoid
nerdfont rendering issues (`>>>` arrows). The theme is defined inline in
`~/.config/zellij/config.kdl` to guarantee it loads correctly.

- **Background**: `#181825` (Base)
- **Selected tab**: `#a6e3a1` (Green)
- **Text**: `#cdd6f4` (Text)

## Sessions

| Command                  | Action                          |
| ------------------------ | ------------------------------- |
| `zellij`                 | Start new session or attach     |
| `zellij attach <name>`   | Attach to named session         |
| `zellij ls`              | List active sessions            |
| `zellij kill-session`    | Kill current session            |

## Integration

- **Editor**: `hx` (Helix) is set as the default editor.
- **Shell**: `zsh` is the default shell.
- **Fastfetch**: Configured in `.zshrc` to run once per Zellij session.

## Troubleshooting

| Issue                  | Solution                                      |
| ---------------------- | --------------------------------------------- |
| Theme not loading      | Ensure `theme: "catppuccin-mocha"` is in config |
| `>>>` instead of arrows| `simplified_ui: true` is set; check terminal font |
| Keys not passing through| Press `Ctrl+n` to ensure you're in normal mode |
