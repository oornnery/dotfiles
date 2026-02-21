# Fzf Cheatsheet

## Core commands

| Command                    | What it does                       |
| -------------------------- | ---------------------------------- |
| `fzf`                      | Open interactive fuzzy selector    |
| `history \| fzf`           | Search shell history interactively |
| `git branch \| fzf`        | Pick a branch quickly              |
| `git log --oneline \| fzf` | Search commits by hash/message     |
| `fd . \| fzf`              | Pick a file from project list      |
| `ps aux \| fzf`            | Fuzzy-find running processes       |

## Useful patterns

| Command                                      | What it does                     |
| -------------------------------------------- | -------------------------------- |
| `rg -n "TODO" \| fzf`                        | Pick one match from grep results |
| `fd -e md docs \| fzf`                       | Pick only Markdown files in docs |
| `fd . \| fzf \| xargs -r batcat`             | Preview selected file            |
| `fd . \| fzf \| xargs -r nvim`               | Open selected file in Neovim     |
| `git branch \| fzf \| xargs -r git checkout` | Interactive branch checkout      |

## Shortcuts

| Shortcut   | Action                                       |
| ---------- | -------------------------------------------- |
| `Ctrl + R` | Fuzzy search shell history (fzf integration) |
| `Tab`      | Complete paths/commands                      |

## Examples

```bash
# Pick and open a file with preview
fd . | fzf --preview 'batcat --style=plain --color=always {}' | xargs -r nvim

# Search TODOs, then open chosen match in editor
rg -n "TODO" | fzf | cut -d: -f1 | xargs -r nvim
```

## Tips

| Tip                                 | Why it helps                          |
| ----------------------------------- | ------------------------------------- |
| Pipe structured output into `fzf`   | Turns long lists into quick selection |
| Keep input concise before `fzf`     | Better matching and less noise        |
| Pair with `fd`/`rg`                 | Fast file and content navigation      |
| Use `--preview` when browsing files | Faster context before opening         |
