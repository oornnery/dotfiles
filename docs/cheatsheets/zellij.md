# Zellij

Panes and tabs in the terminal. It starts locked, so apps keep their keys, and the
keys below always work. Start it with `zellij`, or `zellij -l dev` for the dev layout.

| Key | Action |
| --- | ------ |
| `Alt /` | Command palette: actions, TUIs and dots commands |
| `Alt u` | Pick a TUI, in a floating pane |
| `Alt r` | Run any command, in a new pane |
| `Alt o` | Open a project from zoxide, in a new tab |
| `Alt s` | Sessions |
| `Alt h` `j` `k` `l` | Move between panes |
| `Alt n` | New pane |
| `Alt x` | Close pane |
| `Alt f` | Fullscreen pane |
| `Alt w` | Show or hide floating panes |
| `Alt t` | New tab |
| `Alt [` `]` | Previous and next tab |
| `Alt 1` to `5` | Go to a tab |
| `Ctrl g` | Unlock Zellij's own modes and show their keys |

Do not bind `Alt Enter` or `Alt Space`: Windows Terminal uses them.

In Helix, `Alt n` and a few others are also selection keys. Zellij gets them first.
