# Palette

One search for everything: files and what is in them, TUIs, `dots` commands, keys,
help pages, any command, man pages and pet snippets. fzf, under the prompt in a
shell, and in a floating pane in Zellij.

## Open it

| Key | Opens |
| --- | ----- |
| `Alt /` | Everything (`dots palette`) |
| `Alt ?` | Help pages (`dots palette help`) |
| `Alt u` | TUIs (`dots palette tui`) |

Any mode from the shell: `dots palette <mode>`.

## Inside

| Key | Action |
| --- | ------ |
| `Tab` | Next mode |
| `Shift Tab` | Previous mode |
| `Enter` | Run or open the line |
| `Esc` | Close |
| `Up` `Down` | Move |
| `Shift Up` `Shift Down` | Scroll the preview |
| `Ctrl u` | Clear the search |

From `files`, `Tab` keeps what you typed and searches it inside the files (`grep`).
Both skip `.git`, caches and toolchains, and include hidden files.

Type to filter. `'word` matches it exactly, `^word` at the start, `word$` at the end,
`!word` leaves it out, and a space joins terms.

## Modes

| Mode | Lines | Enter |
| ---- | ----- | ----- |
| `all` | The modes, TUIs, dots commands and help pages | Depends on the line |
| `files` | Files in the folder it opened in, by name | Opens it in the editor |
| `grep` | Lines of those files, searched with rg as you type | Opens the editor at that line |
| `help` | Cheatsheets, aliases, functions, snippets | Opens the page; `q` comes back |
| `keys` | Every key of keys, zellij, neovim and herdr | Opens its sheet; `q` comes back |
| `tui` | TUIs installed | Opens it |
| `dots` | dots commands | Runs it, then waits for a key |
| `run` | Every command in PATH | Runs it |
| `linux` | Man pages | Opens it; `q` comes back |
| `pet` | Pet snippets | Fills it in and runs it |

The preview on the right never runs anything: it shows the sheet, the man page or
the help of the line.
