# Zsh Cheatsheet

## Commands

| Command         | What it does                                    |
| --------------- | ----------------------------------------------- |
| `reload`        | Reloads shell config (`exec zsh`)               |
| `edit`          | Opens `~/.zshrc` in Neovim                      |
| `update`        | Runs `sudo nala update && sudo nala upgrade -y` |
| `install <pkg>` | Installs package via `nala`                     |
| `alias`         | Lists active aliases                            |
| `which <cmd>`   | Shows command path                              |
| `echo $SHELL`   | Shows current shell                             |

## Shortcuts

| Shortcut   | Action                    |
| ---------- | ------------------------- |
| `Ctrl + R` | Search command history    |
| `Ctrl + A` | Move cursor to line start |
| `Ctrl + E` | Move cursor to line end   |
| `Ctrl + W` | Delete previous word      |
| `Ctrl + L` | Clear screen              |
| `!!`       | Re-run last command       |

## Examples

```bash
# Reload config after editing
edit
reload

# Install tools quickly
install ripgrep fd-find

# Check command origin
which rg
alias | grep -E "^(ls|ll|cat)="
```

## Tips

| Tip                                           | Why it helps                                   |
| --------------------------------------------- | ---------------------------------------------- |
| Keep `zsh-syntax-highlighting` as last plugin | Avoids broken highlighting                     |
| Use `alias` to inspect active aliases         | Confirms your shell behavior quickly           |
| Use `source ~/.zshrc` after edits             | Fast config refresh without reopening terminal |
| Keep shell startup lightweight                | Faster terminal startup                        |
