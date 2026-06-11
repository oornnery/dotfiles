# Prompt

[Starship](https://starship.rs) is the prompt. Config lives in
[`zsh/.config/starship.toml`](../../../zsh/.config/starship.toml).

## Philosophy

No hostname. No username. No time. Things that don't change between
commands belong in the title bar, not the prompt.

What does show:

- Current directory (truncated to 3 segments, repo-aware)
- Git branch + status (modified/staged/deleted/ahead/behind)
- Language env, only if relevant: Python venv, Node version, Rust,
  Go, Docker context
- Command duration (only if `> 2s`)
- A pink `❯` on the next line — red if the previous command failed,
  green in vim-cmd mode

## Wiring

`zsh/.zshrc` already has the `command -v starship` guard at the bottom:

```bash
command -v starship >/dev/null && eval "$(starship init zsh)"
```

`starship` reads `$XDG_CONFIG_HOME/starship.toml` (= `~/.config/starship.toml`),
which is stowed in via the `zsh/` package.

## Test changes without restarting

```bash
starship explain        # describe what each module is doing right now
starship config         # opens $EDITOR on the toml file
```

After editing, the next prompt rerun picks up the new config — no shell
reload needed.

## Disable a module

Each one has a `[module]` block. Set `disabled = true`. Already disabled
in the default: `hostname`, `username`, `time`, `battery`, `package`,
`memory_usage`.

## Palette

Pink (`color212`) is the accent — matches alacritty selection,
tmux status, and Hyprland active border. Keep all four in sync if you
re-theme.
