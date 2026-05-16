# Shell Tools

The modern CLI replacements installed by
[`dev/tools.sh`](../../../scripts/arch/dev/tools.sh). All have shell
integrations gated by `command -v` in `.zshrc`, so missing tools are
silent no-ops.

| Tool       | Replaces        | Notable usage                                            |
| ---------- | --------------- | -------------------------------------------------------- |
| eza        | `ls`            | `ls`/`ll`/`la`/`lt`/`lta` aliases                        |
| bat        | `cat`           | `cat`/`catp` aliases; auto-paging for long files         |
| fd         | `find`          | `fd <pattern>` — respects `.gitignore` by default        |
| ripgrep    | `grep -r`       | `rg <pattern>` — fast, gitignore-aware                   |
| fzf        | —               | `Ctrl-T` (paths), `Ctrl-R` (history), `Alt-C` (cd)       |
| zoxide     | `cd`            | `z <hint>` jumps to a freq-visited dir                   |
| atuin      | bash history    | `Ctrl-R` opens TUI history search across machines        |
| starship   | prompt          | see [Prompt](../configuration/03-prompt.md)              |
| mise       | rvm/nvm/pyenv   | language version manager (`.tool-versions` + `.mise.toml`) |
| direnv     | —               | per-directory env (`.envrc`)                             |
| lazygit    | `git` UI        | bound to `Super + Shift + G` in Hyprland                 |
| lazydocker | `docker stats`  | bound to `Super + Shift + D`                             |
| yazi       | ranger          | TUI file manager                                         |
| btop       | htop            | bound to `Super + Shift + T`                             |
| gum        | dialog          | scripts; pretty TUI prompts                              |
| tealdeer   | tldr            | `tldr <cmd>` — concise examples                          |
| github-cli (`gh`) | —        | repo/PR/issue from CLI                                   |
| glab       | —               | gitlab equivalent                                        |

Plus low-level helpers: `jq`, `yq`, `htmlq`, `xmlstarlet`, `whois`,
`inetutils`, `socat`, `procs`, `dust`, `duf`, `sd`, `xh`, `bottom`,
`gping`, `doggo`, `tokei`, `plocate`, `tree-sitter-cli`, `usage`,
`fastfetch`.

## Cheatsheets

Per-tool quick references in [`cheatsheets/`](../cheatsheets/):

- [bat](../cheatsheets/bat.md)
- [eza](../cheatsheets/eza.md)
- [fzf](../cheatsheets/fzf.md)
- [fastfetch](../cheatsheets/fastfetch.md)
- [find](../cheatsheets/find.md) — `fd` cheatsheet
- [grep](../cheatsheets/grep.md) — `rg` cheatsheet
- [git](../cheatsheets/git.md)
- [tmux](../cheatsheets/tmux.md)
- [zsh](../cheatsheets/zsh.md)
