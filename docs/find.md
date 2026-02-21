# Find + Fd Cheatsheet

## Find (classic)

| Command                           | What it does                    |
| --------------------------------- | ------------------------------- |
| `find . -name "*.md"`             | Find Markdown files recursively |
| `find . -type f -name "*.lua"`    | Find files only                 |
| `find . -type d -name ".git"`     | Find directories only           |
| `find . -name "*.md" -maxdepth 2` | Limit depth                     |
| `find . -name "*.tmp" -delete`    | Delete matching files           |
| `find . -type f -mtime -7`        | Files modified in last 7 days   |

## Fd (modern)

| Command                      | What it does               |
| ---------------------------- | -------------------------- |
| `fd name`                    | Find files/folders by name |
| `fd -e md`                   | Find by extension          |
| `fd -t f`                    | Show files only            |
| `fd -t d`                    | Show directories only      |
| `fd -H "^\."`                | Include hidden files       |
| `fd -E node_modules -E .git` | Exclude noisy folders      |
| `fd -a <name>`               | Show absolute paths        |
| `fd -x echo {}`              | Execute command per result |

## Find vs fd

| Tool   | Best use                                 |
| ------ | ---------------------------------------- |
| `find` | Complex predicates and POSIX portability |
| `fd`   | Fast and simple day-to-day file search   |

## Combined workflows

| Command                               | What it does                            |
| ------------------------------------- | --------------------------------------- |
| `fd -e md docs \| fzf`                | Pick Markdown file in docs              |
| `fd -t f \| xargs -r rg -n "pattern"` | Search pattern in files returned by fd  |
| `find . -name "*.md" \| fzf`          | Interactive selection using find output |
| `fd -e md docs \| xargs -r wc -l`     | Count lines in markdown files           |

## Examples

```bash
# Find hidden config files
fd -H "^\.z"

# Locate recently changed shell scripts
find . -type f -name "*.sh" -mtime -3

# List markdown files and open one with fzf
fd -e md docs | fzf | xargs -r nvim
```

## Tips

| Tip                                       | Why it helps                       |
| ----------------------------------------- | ---------------------------------- |
| Use `fd` for speed and readability        | Cleaner syntax than complex `find` |
| Use `find` when you need advanced filters | Time, size, exact predicates       |
| Exclude `.git` and `node_modules` early   | Faster scans and cleaner results   |
| Prefer `fd` for daily interactive usage   | Better defaults and faster UX      |
