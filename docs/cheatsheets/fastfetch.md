# Fastfetch Cheatsheet

## Commands

| Command                         | What it does             |
| ------------------------------- | ------------------------ |
| `fastfetch`                     | Prints system summary    |
| `fastfetch --list-config-paths` | Shows config locations   |
| `fastfetch --gen-config`        | Generates default config |
| `fastfetch --help`              | Shows all options        |
| `fastfetch --config <path>`     | Uses a custom config     |
| `fastfetch --logo none`         | Disables logo output     |

## Shortcuts

| Shortcut             | Action                          |
| -------------------- | ------------------------------- |
| `Up Arrow` + `Enter` | Re-run last `fastfetch` command |
| `Ctrl + L`           | Clear screen before rerun       |

## Examples

```bash
# Generate config and edit it
fastfetch --gen-config
nvim ~/.config/fastfetch/config.jsonc

# Run with minimal output
fastfetch --logo none
```

## Tips

| Tip                        | Why it helps                      |
| -------------------------- | --------------------------------- |
| Run once on shell startup  | Quick environment check           |
| Keep output minimal        | Faster shell startup              |
| Store config in dotfiles   | Consistent output across machines |
| Use custom config per host | Easy machine-specific tweaks      |
