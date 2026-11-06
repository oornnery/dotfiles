# Zellij

Panes and tabs in the terminal. The bar at the bottom always shows the current mode
and its keys, like the statusline in Helix. Press `Esc` to leave a mode.

Start it with `zellij`, or `zellij -l dev` for the dev layout.

## Help and menus

| Key | Action |
| --- | ------ |
| `Alt /` | Command palette: actions, TUIs and dots commands |
| `Alt ?` | This page (`q` closes it) |
| `Alt u` | Pick a TUI, in a floating pane |
| `Alt r` | Run any command, in a new pane |
| `Alt o` | Open a project from zoxide, in a new tab |

## Modes

| Key | Mode | For |
| --- | ---- | --- |
| `Alt p` | Pane | New, close, rename, fullscreen, floating |
| `Alt b` | Tab | New, close, rename, move |
| `Alt z` | Resize | Change the size of a pane |
| `Alt m` | Move | Move a pane around |
| `Alt v` | Scroll | Scroll and search what a pane printed |
| `Alt g` | Session | Detach, switch and manage sessions |

## Direct keys

| Key | Action |
| --- | ------ |
| `Alt h` `j` `k` `l` | Move between panes |
| `Alt n` | New pane |
| `Alt x` | Close pane |
| `Alt f` | Fullscreen pane |
| `Alt w` | Show or hide floating panes |
| `Alt e` | Open what the pane printed in the editor |
| `Alt t` | New tab |
| `Alt [` `]` | Previous and next tab |
| `Alt 1` to `5` | Go to a tab |
| `Alt d` | Leave; the session keeps running (`zellij attach` comes back) |
| `Alt q` | End this session |

Do not bind `Alt Enter` or `Alt Space`: Windows Terminal uses them. Some Alt keys are
also selection keys in Helix, and Zellij gets them first.
