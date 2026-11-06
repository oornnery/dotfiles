# Fzf Cheatsheet

Fuzzy finder for files, history, commands, anything. Integrated with zsh
(`source <(fzf --zsh)`), used by `fzf-tab` for completion, and by many
scripts in this repo.

## Shell integration

| Bind       | Action                                                  |
| ---------- | ------------------------------------------------------- |
| `Ctrl + R` | Fuzzy search shell history                              |
| `Ctrl + T` | Insert file/dir paths under cursor                      |
| `Alt + C`  | `cd` into selected directory                            |
| `Tab`      | Trigger `fzf-tab` (fzf-powered completion for any cmd)  |

## Core commands

| Command                    | What                               |
| -------------------------- | ---------------------------------- |
| `fzf`                      | Interactive fuzzy selector         |
| `history \| fzf`           | Search shell history               |
| `git branch \| fzf`        | Pick a branch                      |
| `git log --oneline \| fzf` | Search commits by hash/message     |
| `fd . \| fzf`              | Pick a file                        |
| `ps aux \| fzf`            | Fuzzy-find process                 |

## Filtering syntax (inside fzf)

| Pattern    | Means                                         |
| ---------- | --------------------------------------------- |
| `term`     | Fuzzy match (default)                         |
| `'term`    | Exact substring                               |
| `^term`    | Prefix                                        |
| `term$`    | Suffix                                        |
| `!term`    | Negation (NOT containing)                     |
| `term1 \| term2` | OR (in extended mode)                   |
| `term1 term2` | AND (both must match)                      |

## Useful patterns

| Command                                      | What                             |
| -------------------------------------------- | -------------------------------- |
| `rg -n "TODO" \| fzf`                        | Pick one match from grep results |
| `fd -e md docs \| fzf`                       | Pick MD files in docs            |
| `fd . \| fzf \| xargs -r bat`                | Preview selected file with bat   |
| `fd . \| fzf \| xargs -r nvim`               | Open selected in Neovim          |
| `git branch \| fzf \| xargs -r git checkout` | Interactive branch checkout      |
| `man -k . \| fzf \| awk '{print $1}' \| xargs man` | Pick a man page          |

## Key bindings inside fzf

| Key          | Action                                |
| ------------ | ------------------------------------- |
| `Enter`      | Select                                |
| `Esc`        | Cancel                                |
| `Tab`        | Mark for multi-select (with `--multi`)|
| `Ctrl-j/k`   | Move down/up                          |
| `Ctrl-d/u`   | Half-page down/up                     |
| `Alt-Enter`  | Confirm + keep selected                |
| `Ctrl-q`     | Select all matches                    |
| `Ctrl-/`     | Toggle preview window                 |
| `?`          | Show help                             |

## Preview tricks (in this repo)

```bash
# File preview with bat colors
fzf --preview 'bat --style=numbers --color=always {}'

# Directory tree preview with eza (already wired into fzf-tab for cd)
fzf --preview 'eza --tree --color=always {}'

# Git diff preview for branch picker
git branch | fzf --preview 'git log --color {1}'
```

## Aliases in this repo

| Alias  | Expands to                                              |
| ------ | ------------------------------------------------------- |
| `ff`   | `fzf --preview "bat --style=numbers --color=always {}"` |

## fzf-tab (better completion UI)

OMZ plugin that replaces tab completion with fzf:
- `cd Tab` → fzf picker over dirs with `eza --tree` preview
- `git checkout Tab` → fzf over branches
- Any command Tab → fuzzy pick from completions

Configured at `~/.zshrc`:
```zsh
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza --tree --color=always $realpath'
zstyle ':fzf-tab:complete:*' use-fzf-default-opts yes
```

## Common recipes

```bash
# Pick and open a file with preview
fd . | fzf --preview 'bat --style=plain --color=always {}' | xargs -r nvim

# Search TODOs across project, jump to chosen match
rg -n "TODO" | fzf | cut -d: -f1 | xargs -r nvim

# Interactive process kill
ps aux | fzf | awk '{print $2}' | xargs -r kill

# Fuzzy-pick a recent dir (zoxide alternative)
zoxide query -l | fzf | xargs cd
```

## Tips

| Tip                                       | Why                                  |
| ----------------------------------------- | ------------------------------------ |
| Pipe structured output into `fzf`         | Turns long lists into quick picks    |
| Use `--preview` for files/branches/diff   | Faster context before opening        |
| Combine with `fd`/`rg`                    | Native fzf + modern tools = fast     |
| `fzf-tab` for daily completion            | Discoverable previews while typing   |
| `Ctrl + T` in shell to insert path        | Avoids cd → ls → cd → ls cycles      |
| `Alt + C` for cd-into-anything            | Top-level shell navigation           |
