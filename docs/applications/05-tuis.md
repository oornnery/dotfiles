# TUIs

Terminal UIs that replace heavy GUI tools. Installed via `dev/tools.sh`
(general) and `core/bluetooth.sh` (bluetui) / `core/networkmanager.sh`
(impala). All bound in Hyprland to open in a floating Alacritty window.

| Bind                      | Tool       | What for                          |
| ------------------------- | ---------- | --------------------------------- |
| `Super + Shift + G`       | lazygit    | Git operations                    |
| `Super + Shift + D`       | lazydocker | Docker / containers               |
| `Super + Shift + T`       | btop       | CPU / RAM / disk / GPU monitoring |
| `Super + Shift + B`       | bluetui    | Bluetooth pairing                 |
| `Super + Shift + W`       | impala     | Wi-Fi (iwd backend only)          |
| `Super + Shift + Alt + M` | cliamp     | Music control                     |

## Inside a TUI

Most accept `?` for help. lazygit + lazydocker use vim-like nav (`hjkl`).
`q` to quit; the floating Alacritty window closes automatically.

### lazygit

Verified against upstream's [generated keybinding list](https://github.com/jesseduffield/lazygit/blob/master/docs/keybindings/Keybindings_en.md);
`?` in the app opens the same menu.

| Key       | Scope  | Action                                     |
| --------- | ------ | ------------------------------------------ |
| `space`   | Files  | Stage / unstage the selected file          |
| `a`       | Files  | Stage / unstage everything                 |
| `c` / `C` | Files  | Commit staged / commit with the git editor |
| `A`       | Files  | Amend the last commit                      |
| `Ctrl+f`  | Files  | Find the commit to fixup into              |
| `s` / `S` | Files  | Stash all / stash options                  |
| `d`       | Files  | Discard changes (with options)             |
| `e`       | Files  | Open the file in `$EDITOR`                 |
| `z` / `Z` | Global | Undo / redo the last git command (reflog)  |
| `P` / `p` | Global | Push / pull the current branch             |
| `m`       | Global | Merge / rebase options                     |
| `:`       | Global | Run a shell command inside lazygit         |
| `[` / `]` | Panels | Previous / next tab                        |
| `/`       | Panels | Filter the current view                    |
| `q`       | Global | Quit                                       |

### lazydocker

| Key             | Scope      | Action                                                    |
| --------------- | ---------- | --------------------------------------------------------- |
| `1`…`5`         | Global     | Focus projects / services / containers / images / volumes |
| `[` / `]`       | Project    | Previous / next tab                                       |
| `m`             | Containers | View logs                                                 |
| `E`             | Containers | Exec a shell                                              |
| `a`             | Containers | Attach                                                    |
| `s` / `r` / `p` | Containers | Stop / restart / pause                                    |
| `d`             | Containers | Remove                                                    |
| `e`             | Containers | Hide or show stopped containers                           |
| `w`             | Containers | Open the first port in the browser                        |
| `/`             | Project    | Filter the list                                           |
| `?`             | Global     | Keybindings                                               |

## Inside a herdr pane

Both run fine in a [herdr](herdr.md) pane, and their `hjkl` keys are why pane
navigation here is bound to `Alt+h/j/k/l` rather than `Ctrl+h/j/k/l`. To let a TUI
keep the chord itself, add it to the passthrough regex where you launch herdr:

```bash
export HERDR_NAV_PASSTHROUGH_RE='^(lazygit|lazydocker)$'
```

## Floating window class

Binds pass `--class floating` to Alacritty. Add a windowrule in
[`hyprland.conf`](../../../hyprland/.config/hypr/hyprland.conf) if you
want all `floating` class windows to spawn centered, sized, with no
shadow:

```ini
windowrule {
    name = floating-tui
    match:class = floating
    float = yes
    center = 1
    size = 1200 800
}
```

(Add to your windowrules block if you don't have one yet.)

## fastfetch

Not bound — runs once per login from `.zshrc`. `unset FASTFETCH_SHOWN`
in a shell if you want to see it again.
