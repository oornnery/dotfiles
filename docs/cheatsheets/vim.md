# Vim

The editor for machines with only vim: `dots link vim` links `~/.vimrc`. No
plugins, and the same `Space` keys as Helix. Here Helix is the daily one.

## Space keys

| Key | Action |
| --- | ------ |
| `Space Space` | Find a file (`:find`, searches below this folder) |
| `Space e` | File explorer (netrw) |
| `Space w` `Space q` | Save, quit |
| `Space v` | Split side by side |
| `Tab` `Shift Tab` | Next, previous open file |
| `Ctrl h` `j` `k` `l` | Move between splits |
| `Esc` | Clear the search highlight |
| `gc` | Comment (vim 9.1+) |

## The basics

| Key | Action |
| --- | ------ |
| `i` `a` `o` | Insert before, after, on a new line |
| `Esc` | Back to normal mode |
| `:w` `:q` `:wq` `:q!` | Save, quit, both, quit without saving |
| `h` `j` `k` `l`, `w` `b` | Move, by word |
| `gg` `G`, `:42` | Top, bottom, line 42 |
| `dd` `yy` `p` | Cut a line, copy a line, paste |
| `u` `Ctrl r` | Undo, redo |
| `/word` `n` `N` | Search, next, previous |
| `:%s/old/new/g` | Replace in the file |
| `v` `V` `Ctrl v` | Select characters, lines, a block |
| `>` `<` | Indent the selection (stays selected) |
| `.` | Repeat the last change |

## Settings worth knowing

- Undo survives closing the file (`~/.vim/undo`); swap files go to `~/.vim/swap`.
- It reopens a file where you left it, uses the system clipboard and the mouse.
- Spaces, 2 wide; search ignores case unless you type a capital.
- Colors come from `dots theme` (`~/.vim/theme.vim`).
