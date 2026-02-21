# Bat Cheatsheet

## Commands

| Command                        | What it does                 |
| ------------------------------ | ---------------------------- |
| `cat <file>`                   | Alias to `batcat <file>`     |
| `catp <file>`                  | Plain output via `batcat -p` |
| `batcat --style=plain <file>`  | No decorations               |
| `batcat --paging=never <file>` | Disable pager                |
| `batcat -n <file>`             | Show line numbers            |
| `batcat -A <file>`             | Show invisible characters    |

## Shortcuts

| Shortcut | Action                 |
| -------- | ---------------------- |
| `q`      | Quit pager view        |
| `/text`  | Search in pager output |

## Examples

```bash
# Read config with syntax highlighting
cat ~/.zshrc

# Use plain output for scripts/pipes
catp README.md

# Inspect whitespace problems
batcat -A docs/README.md
```

## Tips

| Tip                                     | Why it helps                              |
| --------------------------------------- | ----------------------------------------- |
| Use `catp` for scripts/pipes            | Cleaner output for tooling                |
| Use highlighted `cat` for config review | Faster spotting of syntax issues          |
| Disable paging in scripts               | Prevents blocking CI/non-interactive runs |
| Use line numbers during reviews         | Easier discussion and navigation          |
