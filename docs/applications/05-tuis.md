# TUIs

Terminal UIs that replace heavy GUI tools. Installed via `dev/tools.sh`
(general) and `core/bluetooth.sh` (bluetui) / `core/networkmanager.sh`
(impala). All bound in Hyprland to open in a floating Alacritty window.

| Bind                  | Tool       | What for                            |
| --------------------- | ---------- | ----------------------------------- |
| `Super + Shift + G`   | lazygit    | Git operations                      |
| `Super + Shift + D`   | lazydocker | Docker / containers                 |
| `Super + Shift + T`   | btop       | CPU / RAM / disk / GPU monitoring   |
| `Super + Shift + B`   | bluetui    | Bluetooth pairing                   |
| `Super + Shift + W`   | impala     | Wi-Fi (iwd backend only)            |
| `Super + Shift + Alt + M` | cliamp | Music control                       |

## Inside a TUI

Most accept `?` for help. lazygit + lazydocker use vim-like nav (`hjkl`).
`q` to quit; the floating Alacritty window closes automatically.

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
