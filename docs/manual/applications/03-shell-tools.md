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

The [docs/](../../) folder has per-tool quick references that go deeper:

- [bat](../../bat.md)
- [eza](../../eza.md)
- [fzf](../../fzf.md)
- [fastfetch](../../fastfetch.md)
- [find](../../find.md) — `fd` cheatsheet
- [grep](../../grep.md) — `rg` cheatsheet
- [git](../../git.md)
- [tmux](../../tmux.md)
- [zsh](../../zsh.md)
