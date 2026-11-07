# Bat Cheatsheet

## Commands

| Command                        | What it does                 |
| ------------------------------ | ---------------------------- |
| `b <file>`                     | Alias to `bat <file>`        |
| `bat -p <file>`                | Plain output                 |
| `bat --style=plain <file>`  | No decorations               |
| `bat --paging=never <file>` | Disable pager                |
| `bat -n <file>`             | Show line numbers            |
| `bat -A <file>`             | Show invisible characters    |

## Shortcuts

| Shortcut | Action                 |
| -------- | ---------------------- |
| `q`      | Quit pager view        |
| `/text`  | Search in pager output |

## Examples

```bash
# Read config with syntax highlighting
bat ~/.zshrc

# Use plain output for scripts/pipes
bat -p README.md

# Inspect whitespace problems
bat -A docs/README.md
```

## Tips

| Tip                                     | Why it helps                              |
| --------------------------------------- | ----------------------------------------- |
| Use `bat -p` for scripts/pipes            | Cleaner output for tooling                |
| Use `bat` for config review | Faster spotting of syntax issues          |
| Disable paging in scripts               | Prevents blocking CI/non-interactive runs |
| Use line numbers during reviews         | Easier discussion and navigation          |
