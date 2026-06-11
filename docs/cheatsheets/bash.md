# Bash Cheatsheet

## Commands

| Command                  | What it does                  |
| ------------------------ | ----------------------------- |
| `bash scripts/debian.sh` | Runs Debian bootstrap script  |
| `source ~/.bashrc`       | Reloads Bash config           |
| `echo $PATH`             | Shows executable search path  |
| `type <command>`         | Shows how command is resolved |
| `bash -n script.sh`      | Syntax-check script only      |
| `set -x`                 | Debug command execution       |
| `set +x`                 | Stop debug mode               |

## Shortcuts

| Shortcut   | Action                     |
| ---------- | -------------------------- |
| `Ctrl + C` | Stops current process      |
| `Ctrl + L` | Clears terminal screen     |
| `Ctrl + U` | Deletes text before cursor |
| `Ctrl + K` | Deletes text after cursor  |
| `Ctrl + A` | Move cursor to start       |
| `Ctrl + E` | Move cursor to end         |

## Examples

```bash
# Check script before running
bash -n scripts/debian.sh

# Run with tracing (debug)
bash -x scripts/debian.sh

# Reload shell config
source ~/.bashrc
```

## Tips

| Tip                                 | Why it helps                      |
| ----------------------------------- | --------------------------------- |
| Use Bash for script compatibility   | Many system scripts assume Bash   |
| Keep interactive-only logic guarded | Avoids script side effects        |
| Put reusable aliases in one place   | Easier maintenance between shells |
| Use `bash -n` in CI/pre-commit      | Catches syntax errors early       |
