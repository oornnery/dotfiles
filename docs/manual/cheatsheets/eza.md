# Eza + Tree Cheatsheet

## Commands

| Command         | What it does                                 |
| --------------- | -------------------------------------------- |
| `ls`            | Alias to `eza --color=always --icons=always` |
| `ll`            | Alias to `eza -la --icons=always --git`      |
| `tree`          | Alias to `eza --tree --icons=always`         |
| `eza -T -L 2`   | Tree view up to 2 levels                     |
| `eza -la`       | Show hidden files in long format             |
| `eza -la --git` | Show Git status per file                     |
| `eza -lh`       | Human-readable file sizes                    |

## Shortcuts

| Shortcut   | Action                  |
| ---------- | ----------------------- |
| `Tab`      | Path completion         |
| `Ctrl + L` | Clear and rerun listing |

## Examples

```bash
# Project overview
ll

# Compact tree for docs folder
eza -T -L 2 docs

# List only directories
eza -D
```

## Tips

| Tip                                | Why it helps                    |
| ---------------------------------- | ------------------------------- |
| Use `ll` inside git repos          | Shows git-aware listing quickly |
| Keep tree depth small (`-L`)       | Faster output and less noise    |
| Prefer icons in interactive shells | Better readability              |
| Use `-lh` for large folders        | Easier size inspection          |
