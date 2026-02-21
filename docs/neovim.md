# Neovim (LazyVim) Cheatsheet

## Commands

| Command        | What it does                 |
| -------------- | ---------------------------- |
| `nvim`         | Opens Neovim                 |
| `:Lazy`        | Opens plugin manager UI      |
| `:Mason`       | Opens LSP/tools installer UI |
| `:checkhealth` | Runs environment diagnostics |
| `:qa`          | Quit all windows             |
| `:w`           | Save current buffer          |
| `:e <file>`    | Open file                    |
| `:Telescope`   | Open Telescope pickers       |

## Shortcuts

| Shortcut              | Action                             |
| --------------------- | ---------------------------------- |
| `<Space>ff`           | Find files                         |
| `<Space>fg`           | Live grep in project               |
| `<Space>e`            | Toggle file explorer               |
| `<Space>w`            | Save file                          |
| `<Space>qq`           | Quit all                           |
| `<Space>fb`           | Find buffers                       |
| `<Space>fr`           | Open recent files                  |
| `<Space>bd`           | Delete buffer                      |
| `gcc`                 | Toggle line comment (mini.comment) |
| `gsa` / `gsd` / `gsr` | Add/Delete/Replace surroundings    |

## Examples

```vim
" Find and open files
<Space>ff

" Search text in current project
<Space>fg

" Sync plugins after editing plugin specs
:Lazy sync
```

## Tips

| Tip                                    | Why it helps                          |
| -------------------------------------- | ------------------------------------- |
| Keep plugins in `lua/plugins/*.lua`    | Clear separation from core config     |
| Run `:Lazy sync` after plugin edits    | Ensures plugin state is up to date    |
| Use `:checkhealth` after setup changes | Fast way to find missing dependencies |
| Use Telescope for daily navigation     | Faster than manual file browsing      |
