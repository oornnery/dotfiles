# Keys

The keys of every tool in one page. Open it with `dots help keys`, or search single
keys with `dots palette keys`. Each tool also has its own full list:

| Key | Where the full list is |
| --- | ---------------------- |
| `Alt ?` | Help pages, in the shell and in Zellij |
| `Alt /` | The palette; its keys are in `dots help palette` |
| `Ctrl h` | tv |
| `~` | Yazi |
| `Space ?` | Helix, all commands |

## Shell

In zsh, the Alt keys set aside what you were typing, run, and give the line back. In
bash, use them on an empty line: they type the command after what is there. Inside
Zellij, Zellij takes them first and opens the same things floating.

| Key | Action |
| --- | ------ |
| `Alt /` | Search everything with fzf |
| `Alt ?` | Help pages |
| `Alt u` | Pick a TUI |
| `Alt e` | Yazi; the shell stays in the folder you were in |
| `Alt g` | Lazygit |
| `Ctrl r` | Search history with Atuin |
| `Ctrl x Ctrl r` | Insert a pet snippet |
| `y` | Yazi, as a command |
| `dev` | This folder as a Zellij session |
| `fe` | Pick a file and open it in the editor |
| `prev` | Save the previous command as a pet snippet |
| `fuck` | Fix the previous command |

## Zsh

Emacs keys, its own and from fzf. Aliases and functions have their own pages:
`dots help aliases` and `dots help functions`.

| Key | Action |
| --- | ------ |
| `Tab` | Complete, with fzf |
| `Ctrl t` | Pick a file with fzf and insert it |
| `Alt c` | Pick a folder with fzf and go there |
| `Ctrl a` | Start of the line |
| `Ctrl e` | End of the line |
| `Alt b` | Back a word |
| `Alt f` | Forward a word |
| `Ctrl w` | Delete the word before |
| `Alt d` | Delete the word after |
| `Ctrl u` | Delete the whole line |
| `Ctrl k` | Delete to the end of the line |
| `Ctrl y` | Paste what was deleted |
| `Ctrl _` | Undo |
| `Alt .` | Insert the last word of the previous command |
| `Alt q` | Set the line aside, run another command, and get it back |
| `Alt h` | Manual of the command on the line |
| `Ctrl x Ctrl e` | Edit the line in the editor |
| `Ctrl l` | Clear the screen |
| `Up` `Down` | History that starts with what you typed |

## Zellij

Without Zellij, the mode keys and `Alt 1` `2` `3` do nothing. `Ctrl g` locks it, so every
key reaches the app.

| Key | Action |
| --- | ------ |
| `Ctrl p` | Pane mode |
| `Ctrl t` | Tab mode |
| `Ctrl n` | Resize mode |
| `Ctrl h` | Move mode |
| `Ctrl s` | Scroll and search mode |
| `Ctrl o` | Session mode |
| `Ctrl g` | Lock and unlock |
| `Ctrl q` | Quit |
| `Alt n` | New pane |
| `Alt f` | Show or hide floating panes |
| `Alt 1` `2` `3` | Go to that tab |

## Helix

| Key | Action |
| --- | ------ |
| `Space m` | Read this file with glow |
| `Ctrl y` | Pick a file with yazi |
| `Space Space` | Pick a file |
| `Space F` | Pick a file in this folder |
| `Space b` | Pick an open file |
| `Space /` | Search in all files |
| `Space w` | Save |
| `Space q` | Quit |
| `Space v` | Split the window |
| `Tab` | Next open file |
| `Shift Tab` | Previous open file |

## Yazi

| Key | Action |
| --- | ------ |
| `Enter` | Open the file in Helix |
| `W` | A shell here; a pane in Zellij, and `exit` comes back outside it |
| `T` | A shell here; a tab in Zellij, and `exit` comes back outside it |
| `a` | Create a file; ending in `/`, a folder |
| `r` | Rename |
| `y` | Copy |
| `x` | Cut |
| `p` | Paste |
| `d` | Move to the trash |
| `D` | Delete for good |
| `Space` | Select |
| `.` | Show or hide hidden files |
| `f` | Filter this folder |
| `s` | Search names with fd |
| `S` | Search contents with ripgrep |
| `z` | Jump with fzf |
| `Z` | Jump with zoxide |
| `g h` | Go home |
| `t t` | New tab |
| `[` `]` | Previous and next tab |
| `q` | Quit |

## tv

| Key | Action |
| --- | ------ |
| `Tab` | Show the other channels or modes |
| `Enter` | Confirm |
| `Esc` | Close |
| `Ctrl Space` | Mark a line and go to the next |
| `Ctrl o` | Show or hide the preview |
| `Page Up` `Page Down` | Scroll the preview |
| `Ctrl y` | Copy the line |
| `Ctrl s` | Next source of this channel |
| `Ctrl x` | Actions of this channel |
| `Ctrl h` | Its help |
