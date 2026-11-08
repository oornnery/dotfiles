# Packages and dotfiles

What is on this machine and why, by group. Open it with `dots help packages`.
The real lists are in `packages/*.txt` (`dots pkg save`); after installing or
removing something, update this file too.

Source, when it is not pacman: `aur`, `npm`, `uv`, `cargo`.

## TUIs

`dots tui` (`Alt u`) lists the ones installed. The rest come with `dots install tuis`,
or one setup at a time (`dots install tui-git`); the desktop ones with `tui-desktop`.

### Editors and terminal

| Run | Package | For | Project |
| --- | --- | --- | --- |
| `helix` / `hx` | `helix` | Editor | [helix-editor/helix](https://github.com/helix-editor/helix) |
| `nvim` | `neovim` | Full editor: LSP, debug and tests for any language | [neovim/neovim](https://github.com/neovim/neovim) |
| `zellij` | `zellij` | Panes and tabs | [zellij-org/zellij](https://github.com/zellij-org/zellij) |
| `tmux` | `tmux` | Terminal multiplexer; may be removed, its config stays | [tmux/tmux](https://github.com/tmux/tmux) |
| `herdr` | `herdr-bin` (aur) | Workspaces for AI coding agents | [herdrdev/herdr](https://github.com/herdrdev/herdr) |

### Files and search

| Run | Package | For | Project |
| --- | --- | --- | --- |
| `yazi` | `yazi` | File manager | [sxyazi/yazi](https://github.com/sxyazi/yazi) |
| `tv` | `television` | Fuzzy finder with channels | [alexpasmantier/television](https://github.com/alexpasmantier/television) |
| `glow` | `glow` | Browse and read Markdown | [charmbracelet/glow](https://github.com/charmbracelet/glow) |
| `ncdu` | `ncdu` | Disk usage | [dev.yorhel.nl/ncdu](https://dev.yorhel.nl/ncdu) |

### Git

| Run | Package | For | Project |
| --- | --- | --- | --- |
| `lazygit` / `lg` | `lazygit` | Git | [jesseduffield/lazygit](https://github.com/jesseduffield/lazygit) |
| `serie` | `serie` | The commit graph, with images of the branches | [lusingander/serie](https://github.com/lusingander/serie) |

### System and containers

| Run | Package | For | Project |
| --- | --- | --- | --- |
| `btop` | `btop` | CPU, memory, processes | [aristocratos/btop](https://github.com/aristocratos/btop) |
| `systemctl-tui` | `systemctl-tui` | systemd units: start, stop, their logs | [rgwood/systemctl-tui](https://github.com/rgwood/systemctl-tui) |
| `lazyjournal` | `lazyjournal` (aur) | Logs: journal, files, Docker and Podman | [Lifailon/lazyjournal](https://github.com/Lifailon/lazyjournal) |
| `lazydocker` / `ld` | `lazydocker` | Docker containers, logs, stats | [jesseduffield/lazydocker](https://github.com/jesseduffield/lazydocker) |
| `oxker` | `oxker` (aur) | Docker containers, lighter | [mrjackwills/oxker](https://github.com/mrjackwills/oxker) |
| `pacsea` | `pacsea-bin` (aur) | Search and install pacman and AUR packages | [Firstp1ck/Pacsea](https://github.com/Firstp1ck/Pacsea) |

### Network

| Run | Package | For | Project |
| --- | --- | --- | --- |
| `trip` | `trippy` | traceroute and ping together, with graphs | [fujiapple852/trippy](https://github.com/fujiapple852/trippy) |
| `termshark` | `termshark` | Packets, like Wireshark | [gcla/termshark](https://github.com/gcla/termshark) |
| `lazyssh` | `lazyssh` (aur) | SSH hosts: pick, add, connect | [Adembc/lazyssh](https://github.com/Adembc/lazyssh) |

### Data and APIs

| Run | Package | For | Project |
| --- | --- | --- | --- |
| `posting` | `posting` (aur) | HTTP APIs, like Postman | [darrenburns/posting](https://github.com/darrenburns/posting) |
| `lazysql` | `lazysql` (aur) | Databases: Postgres, MySQL, SQLite... | [jorgerojas26/lazysql](https://github.com/jorgerojas26/lazysql) |
| `fx` | `fx` | JSON, to browse and query | [antonmedv/fx](https://github.com/antonmedv/fx) |
| `tw` | `tabiew` | CSV, Parquet and JSON tables, with SQL | [shshemi/tabiew](https://github.com/shshemi/tabiew) |
| `epycell` | `epycell` (cargo) | Jupyter notebooks in the terminal | [crates.io/crates/epycell](https://crates.io/crates/epycell) |

### Dev

| Run | Package | For | Project |
| --- | --- | --- | --- |
| `mprocs` | `mprocs` (aur) | Several commands side by side: api, worker, front | [pvolok/dekit](https://github.com/pvolok/dekit) |
| `presenterm` | `presenterm` | Slides from Markdown; `presenterm docs/slides/dots.md` | [mfontanini/presenterm](https://github.com/mfontanini/presenterm) |

### Fun

| Run | Package | For | Project |
| --- | --- | --- | --- |
| `spotify_player` | `spotify-player` | Spotify | [aome510/spotify-player](https://github.com/aome510/spotify-player) |
| `ttyper` | `ttyper` | Typing test | [max-niederman/ttyper](https://github.com/max-niederman/ttyper) |

### Desktop

On Arch with Hyprland: `dots install tui-desktop`.

| Run | Package | For | Project |
| --- | --- | --- | --- |
| `wiremix` | `wiremix` | Audio mixer for PipeWire | [tsowell/wiremix](https://github.com/tsowell/wiremix) |
| `impala` | `impala` | Wi-Fi, through iwd | [pythops/impala](https://github.com/pythops/impala) |
| `bluetui` | `bluetui` | Bluetooth | [pythops/bluetui](https://github.com/pythops/bluetui) |

## Shell

| Package | For |
| --- | --- |
| `zsh` | Main shell |
| `atuin` | History search |
| `fzf` | Fuzzy finder: Ctrl-T files, Alt-C folders, Tab with fzf-tab |
| `zoxide` | `z` and `zi`: jump to folders |
| `direnv` | Per-folder `.envrc` |
| `pet-bin` (aur) | Snippets: Ctrl-X Ctrl-R |
| `pay-respects-bin` (aur) | `fuck`: fix the last failed command |
| `fastfetch` | System info when a terminal opens |
| `gum` | Prompts and menus in the `dots` scripts |

## Files and text

| Package | Replaces or does |
| --- | --- |
| `eza` | `ls` (`ll`, `la`, `lt`) |
| `bat` | `cat` (`b`), man pages, fzf previews |
| `fd` | `find` |
| `ripgrep` | `grep` (`rg`) |
| `tree` | Folder tree |
| `jq` | JSON |
| `yq` | YAML, XML, TOML |
| `zip`, `unzip`, `7zip` | Archives; `7z` also opens .7z and .rar |
| `rsync` | Copy and sync folders, also over SSH |
| `sd` | `sed` for find and replace, with plain regexes |
| `dust` | `du` as a tree: what takes the space |
| `duf` | `df` as a table |
| `jless` | Long JSON, folded |
| `htmlq` | `jq` for HTML |
| `xmlstarlet` | Query and edit XML |
| `tealdeer` | `tldr`: short examples of a command |
| `wl-clipboard` | Clipboard for Helix on WSLg |

## Media

| Package | For |
| --- | --- |
| `mpv` | Video and audio player |
| `yt-dlp` | Download video and audio from sites |
| `ttf-firacode-nerd` | Font for Linux GUI apps on WSLg; the terminal uses Windows fonts |

## Git and network

| Package | For |
| --- | --- |
| `git` | Version control |
| `git-delta` | Colored diffs, used as the git pager when installed |
| `github-cli` | `gh`: GitHub |
| `openssh` | `ssh` |
| `wget` | Downloads |
| `xh` | HTTP requests |

## Containers

| Package | For |
| --- | --- |
| `docker`, `docker-buildx`, `docker-compose` | Docker (`d`, `dc`, `dcu`, `dcd`, `dcl`, `dps`) |
| `distrobox` | Other distros inside containers |

## Languages and runtimes

| Package | For |
| --- | --- |
| `uv` | Python projects and tools |
| `mise` | Node, and the tool versions of each project (`mise.toml`) |
| `pnpm` (npm) | Node packages |
| `typescript` (npm) | TypeScript compiler |
| `rust` | Rust and `cargo` |

`vite-plus` (`vp`) is being tested. It comes from its own installer, outside
these lists. It brings a Node too, but the one of mise comes first in `PATH`.

## Helix language servers and formatters

| Package | Language |
| --- | --- |
| `ruff` | Python: lint and format |
| `basedpyright` (uv) | Python: types |
| `bash-language-server`, `shellcheck`, `shfmt` | Shell |
| `taplo-cli` | TOML |
| `marksman` | Markdown |
| `yaml-language-server` | YAML |
| `typescript-language-server` (npm) | TypeScript, JavaScript |
| `vscode-langservers-extracted` (npm) | JSON, HTML, CSS |

Check them with `helix --health`.

## Dev utilities

| Package | For |
| --- | --- |
| `hyperfine` | Benchmark commands |
| `tokei` | Count lines of code |
| `shellcheck` | Lint shell scripts (also used by Helix) |

## System and packages

| Package | For |
| --- | --- |
| `base`, `base-devel` | Arch base and build tools |
| `sudo` | Root commands |
| `man-db`, `man-pages` | `man` |
| `paru` (aur) | AUR helper |
| `pacman-contrib` | `checkupdates`, used by `dots update` |
| `stow` | Links the dotfiles, used by `dots link` |
| `procs` | `ps` with colors and search |
| `pkgfile` | Which package has a command: `pkgfile <command>` |
| `arch-audit` | Installed packages with known security issues |

## To review

Installed, but not part of the setup described above.

| Package | Why it is here |
| --- | --- |
| `paru-debug` (aur) | Debug symbols, created when building paru |

## Dotfiles

Config packages in `home/`, linked by `dots link sync` from `machines/<host>`.

| Package | Holds |
| --- | --- |
| `dots` | The `dots` command and its subcommands |
| `shell` | Shared by zsh and bash: env, aliases, functions, tools, conf.d |
| `zsh` | `.zshrc`, `.zshenv` |
| `bash` | `.bashrc`, `.bash_profile`, `.inputrc` |
| `git` | `.gitconfig` |
| `helix` | Editor and language config |
| `pet` | Snippets and config |
| `distrobox` | `distrobox.conf` |
| `atuin` | History search config; its data stays out of the repo |
| `fastfetch` | System info layout |
| `herdr` | Config and plugin keys; plugins come from a pet snippet |
| `nvim` | Full Neovim config; plugins and servers install on first run |
| `lazygit`, `lazydocker`, `btop`, `yazi` | TUI configs |
| `bat`, `glow`, `mpv` | Tool configs |

Kept but not linked. Turn one on with `dots link <name>`.

| Package | Holds |
| --- | --- |
| `vim` | Small `.vimrc` without plugins, same keys as Helix |
| `tmux` | Small `.tmux.conf`, same theme as Helix |
| `zellij` | Theme, help, the keys for `dots palette` and the `dev` layout |
| `television` | tv and its config; `dots palette` uses fzf |
| `hyprland` | Hyprland, Alacritty, Waybar, Mako, Walker, Wofi and the commands `capture`, `display`, `hypr`, `notifications`, `system`, `webapp`; not used on WSL |

In the repo, but not stow packages:

| Folder | Holds |
| --- | --- |
| `themes/` | Palettes and theme files, used by `dots theme` |
| `ai/` | Claude, Codex, OpenCode and Pi configs, skills and agents; see `ai/README.md` |
| `windows/` | GlazeWM, YASB, Windows Terminal, PowerShell and WSL configs |
| `self-hosted/` | Docker Compose structure; real `.env` files stay out of git |
| `templates/` | Editor templates for new projects |
| `packages/`, `docs/` | Package lists and these cheatsheets |

## Colors

`dots theme` sets the terminal palette, and everything here using ANSI colors
follows: prompt, fzf, bat, eza, lazygit, lazydocker, btop, yazi, fastfetch, glow.
Helix switches to its matching built-in theme.
