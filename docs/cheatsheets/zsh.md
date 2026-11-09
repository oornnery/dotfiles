# Zsh

The main shell. Config in `home/zsh` and `home/shell` (shared with bash); aliases
and functions in `dots help aliases` and `dots help functions`, keys in
`dots help keys`.

## What it has here

| Part | What it does |
| ---- | ------------ |
| Antigen | Loads the plugins below; `compreset` rebuilds completion |
| zsh-completions | More completions |
| fzf-tab | `Tab` completes with fzf, with a preview for folders |
| zsh-autosuggestions | Gray suggestion from history; `Right` takes it |
| zsh-syntax-highlighting | Commands in color while typing; red = not found |
| atuin | `Ctrl r`: history search, across sessions |
| zoxide | `z name`: jump to a folder used before; `zi` picks with fzf |
| direnv | A folder's `.envrc` loads when you enter it |
| mise | Tool versions of each project (`mise.toml`) |
| The prompt | `conf.d/60-prompt.sh`: git, languages, time, pending count |

## History

| Type | Gets |
| ---- | ---- |
| `!!` | The last command (`sudo !!`) |
| `!$` | Its last argument (`Alt .` inserts it) |
| `!*` | All its arguments |
| `^old^new` | The last command with old replaced |
| `!git` | The last command starting with git |
| ` cmd` (leading space) | Not saved in the history |

## Globs

| Glob | Matches |
| ---- | ------- |
| `**/*.md` | Every .md, in every folder below |
| `*(.)` `*(/)` | Only files, only folders |
| `*(om[1,5])` | The 5 newest |
| `*(.L+10M)` | Files over 10 MB |
| `*.{md,txt}` | Both extensions |

## Folders

| Command | Does |
| ------- | ---- |
| `..` `...` | Up one, two |
| `cd -` | Back to the last folder |
| `dirs -v`, `cd -2` | The folder stack, go to one |
| `y` | Yazi; the shell stays where yazi ends |
| `fe` | Pick a file, edit it |

## Fixing things

| Command | Does |
| ------- | ---- |
| `exec zsh` | Reload everything |
| `compreset` | Rebuild completion |
| `zsh -n file` | Check a file's syntax |
| `fuck` | Fix the last failed command (pay-respects) |
| `Ctrl x Ctrl e` | Edit the line in Helix |
