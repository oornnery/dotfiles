# Zellij

Panes and tabs in the terminal, with its default keys. The bar at the bottom always
shows the current mode and its keys. `Esc` or `Enter` leaves a mode.

## Added here

| Key | Action |
| --- | ------ |
| `Alt /` | Search help, TUIs and dots commands with tv |
| `Alt u` | Pick a TUI |
| `Alt ?` | This page (`q` closes it) |

Each one opens in a floating pane that closes when you are done.

## Modes

| Key | Mode | For |
| --- | ---- | --- |
| `Ctrl p` | Pane | New, close, rename, fullscreen, floating |
| `Ctrl t` | Tab | New, close, rename, move |
| `Ctrl n` | Resize | Change the size of a pane |
| `Ctrl h` | Move | Move a pane around |
| `Ctrl s` | Scroll | Scroll and search what a pane printed |
| `Ctrl o` | Session | Detach, switch and manage sessions |
| `Ctrl g` | Locked | Send every key to the app, as in Helix; `Ctrl g` again unlocks |

## Direct keys

| Key | Action |
| --- | ------ |
| `Alt n` | New pane |
| `Alt h` `j` `k` `l` | Move between panes |
| `Alt f` | Show or hide floating panes |
| `Alt +` `-` | Resize the pane |
| `Ctrl q` | Quit |

Use `Ctrl g` inside Helix when a Zellij key gets in the way, like `Ctrl s` or `Ctrl o`.
