# GNU Stow Cheatsheet

## Commands

| Command                    | What it does                      |
| -------------------------- | --------------------------------- |
| `stow -v -t ~ zsh`         | Apply zsh dotfiles                |
| `stow -v -t ~ nvim`        | Apply Neovim dotfiles             |
| `stow -D -v -t ~ zsh`      | Remove zsh symlinks               |
| `stow -n -v -t ~ zsh`      | Dry-run without changes           |
| `stow -R -v -t ~ zsh`      | Restow package                    |
| `stow --adopt -v -t ~ zsh` | Adopt existing files into package |

## Shortcuts

| Shortcut   | Action                             |
| ---------- | ---------------------------------- |
| `Tab`      | Autocomplete package folder names  |
| `Ctrl + R` | Quickly find previous stow command |

## Examples

```bash
# Test before applying
stow -n -v -t ~ nvim

# Apply package
stow -v -t ~ nvim

# Remove package
stow -D -v -t ~ nvim
```

## Tips

| Tip                                 | Why it helps                     |
| ----------------------------------- | -------------------------------- |
| Use dry-run (`-n`) first            | Prevents accidental link changes |
| Backup existing target files        | Avoids overwrite conflicts       |
| Keep one folder per dotfile package | Cleaner symlink management       |
| Restow after package edits          | Keeps links in sync              |
