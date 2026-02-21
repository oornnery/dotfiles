# Grep + Ripgrep Cheatsheet

## Grep (classic)

| Command                          | What it does                  |
| -------------------------------- | ----------------------------- |
| `grep "pattern" file.txt`        | Search text in one file       |
| `grep -n "pattern" file.txt`     | Show matching line numbers    |
| `grep -i "pattern" file.txt`     | Case-insensitive search       |
| `grep -R "pattern" docs/`        | Recursive folder search       |
| `grep -E "TODO\|FIXME" file.txt` | Extended regex (alternatives) |
| `grep -v "pattern" file.txt`     | Show lines that do not match  |

## Ripgrep (`rg`)

| Command                      | What it does                     |
| ---------------------------- | -------------------------------- |
| `rg "pattern"`               | Fast recursive search in project |
| `rg -n "pattern"`            | Include line numbers             |
| `rg -i "pattern"`            | Case-insensitive search          |
| `rg "TODO\|FIXME"`           | Regex alternation search         |
| `rg "pattern" docs/`         | Restrict to one folder           |
| `rg --glob "*.md" "pattern"` | Search only Markdown files       |
| `rg -l "pattern"`            | Show only matching file names    |
| `rg -c "pattern"`            | Count matches per file           |

## Grep vs ripgrep

| Tool   | Best use                                 |
| ------ | ---------------------------------------- |
| `grep` | Quick one-file search or POSIX scripts   |
| `rg`   | Default choice for large repos/codebases |

## Combined workflows

| Command                                       | What it does                     |
| --------------------------------------------- | -------------------------------- |
| `rg -n "pattern" \| fzf`                      | Pick one result interactively    |
| `rg -n "pattern" docs \| cut -d: -f1 \| uniq` | List files containing matches    |
| `rg -n "pattern" --glob "*.{md,lua}"`         | Search multiple extensions       |
| `rg -n "old_value" docs`                      | Locate candidates before replace |

## Examples

```bash
# Search all markdown docs for TODO/FIXME
rg -n "TODO|FIXME" docs --glob "*.md"

# Find files with a specific key
rg -l "colorscheme" nvim

# Count how many matches each file has
rg -c "TODO" docs
```

## Tips

| Tip                                 | Why it helps               |
| ----------------------------------- | -------------------------- |
| Prefer `rg` over `grep -R` in repos | Usually much faster        |
| Always add `-n` while coding        | Faster jump to exact line  |
| Use folder scope (`docs/`, `src/`)  | Better signal-to-noise     |
| Use `rg -l` before bulk changes     | Safer refactoring workflow |
