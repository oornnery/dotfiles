# Zellij

Panes and tabs in the terminal, with its default keys. The bar at the bottom always
shows the current mode and its keys. `Esc` or `Enter` leaves a mode.

Both bars are [zjstatus](https://github.com/dj95/zjstatus), a plugin that
`dots install zellij` downloads. On a new machine it asks for permission inside the
bars, where keys do not reach it: click a bar, then press `y`.

## Added here

| Key | Action |
| --- | ------ |
| `Alt /` | Search everything with tv; `Tab` there switches modes |
| `Alt u` | Pick a TUI |
| `Alt ?` | Search the help pages with tv, this one included |
| `Alt e` | Yazi |
| `Alt g` | Lazygit |
| `Alt 1` `2` `3` | Go to that tab |

Each one opens in a floating pane that closes when you are done, except the tabs.

## With yazi and Helix

These work inside and outside Zellij. Inside, what opens gets its own pane; outside,
it takes over the terminal until it ends. `Alt e` and `Alt g` also work on the shell
prompt, and there `y` leaves the shell in the folder you were in.

| Where | Key | Action |
| ----- | --- | ------ |
| Yazi | `Enter` | Open the file in Helix |
| Yazi | `W` | A shell here |
| Yazi | `T` | A shell here, as a tab |
| Helix | `Ctrl y` | Pick a file with yazi |
| Helix | `Space m` | Read this file with glow |
| Shell | `dev` | This folder as a session: yazi and Helix, lazygit, a shell |

Each tool has its own tabs:

| Action | Zellij | Yazi | Helix |
| ------ | ------ | ---- | ----- |
| New | `Ctrl t` `n` | `t` `t` | `:new` |
| Next, previous | `Ctrl t` `l` `h` | `]` `[` | `Tab` `Shift Tab` |
| Go to number | `Alt 1` `2` `3` | `1` to `9` | |
| Close | `Ctrl t` `x` | `Ctrl c` | `:bc` |

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
