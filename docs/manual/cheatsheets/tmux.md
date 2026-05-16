# Tmux Cheatsheet

## Commands

| Command                       | What it does               |
| ----------------------------- | -------------------------- |
| `tmux`                        | Starts a new tmux session  |
| `tmux ls`                     | Lists sessions             |
| `tmux attach -t <name>`       | Attaches to a session      |
| `tmux kill-session -t <name>` | Kills a session            |
| `tmux new -s <name>`          | Starts a named session     |
| `tmux rename-session -t a b`  | Renames session `a` to `b` |

## Shortcuts

| Shortcut            | Action           |
| ------------------- | ---------------- |
| `Ctrl + b` then `c` | New window       |
| `Ctrl + b` then `,` | Rename window    |
| `Ctrl + b` then `%` | Vertical split   |
| `Ctrl + b` then `"` | Horizontal split |
| `Ctrl + b` then `d` | Detach session   |
| `Ctrl + b` then `n` | Next window      |
| `Ctrl + b` then `p` | Previous window  |
| `Ctrl + b` then `x` | Kill pane        |

## Examples

```bash
# Create and attach to a project session
tmux new -s dotfiles

# Reattach later
tmux attach -t dotfiles

# List all active sessions
tmux ls
```

## Tips

| Tip                            | Why it helps                      |
| ------------------------------ | --------------------------------- |
| Name sessions per project      | Faster context switching          |
| Keep long tasks in tmux        | Safe against terminal disconnects |
| Use `tmux ls` before attaching | Avoids attaching wrong session    |
| Keep one window per task       | Cleaner working context           |
