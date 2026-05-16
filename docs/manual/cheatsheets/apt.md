# Nala + Apt Cheatsheet

## Commands

| Command                   | What it does                                      |
| ------------------------- | ------------------------------------------------- |
| `update`                  | Alias: `sudo nala update && sudo nala upgrade -y` |
| `install <pkg>`           | Alias: `sudo nala install <pkg>`                  |
| `sudo nala search <name>` | Search packages                                   |
| `sudo apt install <pkg>`  | Fallback package install                          |
| `sudo nala remove <pkg>`  | Remove package                                    |
| `sudo apt autoremove`     | Remove unused dependencies                        |
| `sudo nala history`       | Show package operation history                    |

## Shortcuts

| Shortcut             | Action                                 |
| -------------------- | -------------------------------------- |
| `Up Arrow` + `Enter` | Re-run previous install/update command |
| `Ctrl + C`           | Cancel install/upgrade safely          |

## Examples

```bash
# Full update cycle
update

# Search and install tools
sudo nala search ripgrep
install ripgrep fd-find

# Cleanup
sudo apt autoremove
```

## Tips

| Tip                                     | Why it helps                  |
| --------------------------------------- | ----------------------------- |
| Use `nala` for nicer output and history | Better UX than plain apt      |
| Run updates before big installs         | Reduces dependency conflicts  |
| Keep apt as fallback                    | Useful if nala is unavailable |
| Use `history` to audit changes          | Easier rollback/debug         |
