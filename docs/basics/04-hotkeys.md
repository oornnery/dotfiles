# Hotkeys

Master list lives in [Navigation](03-navigation.md). The raw source of
truth is [`hyprland/.config/hypr/bindings.conf`](../../../hyprland/.config/hypr/bindings.conf)
— grep that file when you can't remember a bind:

```bash
grep -E '^bind' ~/.config/hypr/bindings.conf | column -t -s,
```

Tmux bindings: see [Terminal → Tmux config](../applications/01-terminal.md#tmux-config).

Shell aliases: `alias | grep <pattern>` and look at
[`zsh/.zshrc`](../../../zsh/.zshrc).
