# dots

Run `dots` alone for a menu, or press Tab after `dots`. In a checklist, `x` marks,
`Enter` confirms and `Esc` cancels.

| Task | Command |
| ---- | ------- |
| See what is pending (commits, links, packages) | `dots status` (`-f` asks the remote too) |
| See what is wrong and fix it | `dots doctor` |
| Choose which configs are linked | `dots link` |
| Add a config to the repo | `dots link add` |
| Edit a config | `dots edit` |
| Install a package and save it | `dots pkg add <name>` |
| Remove a package and save it | `dots pkg remove [name]` |
| Compare installed and saved | `dots pkg diff` |
| Install ready-made setups | `dots install`, or by group: `dots install languages` |
| See every setup | `dots install --list` |
| Upgrade everything | `dots update` |
| Switch colors | `dots theme` |
| Open a TUI | `dots tui` |
| See all the keys, of every tool | `dots help keys` |
| Search TUIs, commands, keys, help, man pages, snippets | `dots palette [mode]` (`Alt /` in Zellij); `Tab` switches modes |
| Run in a new Zellij pane, or here outside it | `dots pane [--float \| --tab] [command]` |
| Make this machine match the repo | `dots apply` |
| Copy configs to Windows, or only compare | `dots wsl windows [-n]` |
| Bring back configs changed on Windows | `dots wsl windows pull` |
| Save the winget package list | `dots wsl windows export` |
| Install the saved winget packages | `dots wsl windows install` |
| Read these pages | `dots help` |

With the `hyprland` package linked, also: `dots capture`, `dots display`,
`dots hypr`, `dots notifications`, `dots system` and `dots webapp`.
