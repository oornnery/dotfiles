# Modern CLI Tools Cheatsheet

Rust-based replacements + quality-of-life tools installed by
`scripts/arch/dev/cli-tools.sh`. All aliases gate on `command -v` so the
config is safe even before installation.

## Essential replacements

| Tool       | Replaces | Alias  | One-liner usage                                 |
| ---------- | -------- | ------ | ----------------------------------------------- |
| `bottom`   | top/htop | `top`  | `btm` — graphs, multi-CPU, network/disk panes   |
| `dust`     | du       | `du`   | `dust` — visual tree, sorted by size            |
| `duf`      | df       | `df`   | `duf` — colored table per filesystem            |
| `procs`    | ps       | `ps`   | `procs` — tree view, search, watch              |
| `sd`       | sed      | (none) | `sd 'old' 'new' file` — sane regex              |
| `xh`       | curl     | `http` | `xh GET httpbin.org/json` — httpie clone        |
| `tldr`     | man      | (none) | `tldr tar` — short examples                     |
| `jless`    | (jq nav) | (none) | `cat file.json \| jless` — interactive viewer   |
| `git-delta`| git diff | (auto) | configured as git pager — colors + line nums    |

## Pay-respects (typo corrector)

After a failed command, type `f` to get a suggested fix.

```bash
$ giit status
zsh: command not found: giit
$ f
[pay-respects] sugesting: git status
```

Activated in `.zshrc` if `pay-respects` binary exists:
```bash
eval "$(pay-respects zsh --alias f)"
```

## Topgrade (universal updater)

```bash
topgrade           # interactive: pacman + paru + nvim Lazy + tmux plugins + cargo + npm + …
topgrade --dry-run # see what it would do
topgrade -y        # non-interactive
```

Coexists with the repo's `update` script — `update` is curated/scripted,
`topgrade` is the everything-bagel.

## Gum (TUI prompts in scripts)

For your own shell scripts when you want a nice prompt:

```bash
gum input --placeholder "Project name"
gum choose --header "Branch:" $(git branch | tr -d ' *')
gum confirm "Deploy?" && deploy.sh
gum spin --title "Building…" -- cargo build
gum style --border rounded --padding "1 2" --foreground 212 "Done!"
```

## Forgit (git + fzf interactive)

OMZ plugin — adds `g<x>` commands with fzf preview:

| Command   | What                                  |
| --------- | ------------------------------------- |
| `ga`      | Interactive `git add` with diff preview |
| `glo`     | Interactive `git log` browser         |
| `gd`      | Interactive `git diff`                |
| `grh`     | Interactive `git reset HEAD`          |
| `gcf`     | Interactive `git checkout file`       |
| `gcb`     | Interactive `git checkout branch`     |
| `gss`     | Interactive `git stash`               |
| `gsp`     | Interactive `git stash pop`           |
| `gclean`  | Interactive `git clean`               |
| `grb`     | Interactive `git rebase`              |

## zsh-defer (async startup)

Loaded as first OMZ plugin. Configured in `.zshrc` to defer slow inits:

```zsh
if (( $+functions[zsh-defer] )); then
    zsh-defer eval "$(fnm env --use-on-cd)"
    zsh-defer eval "$(atuin init zsh)"
    zsh-defer eval "$(mise activate zsh)"
    zsh-defer eval "$(direnv hook zsh)"
fi
```

Result: starship + zoxide load synchronously (prompt + cd hook are critical),
everything else fires after the first prompt is rendered. Saves ~200ms.

## Bottom (`btm`) — system monitor

| Key       | Action                            |
| --------- | --------------------------------- |
| `?`       | Help                              |
| `q`       | Quit                              |
| `Tab`     | Cycle widgets                     |
| `e`       | Expand current widget             |
| `/`       | Search processes (in proc widget) |
| `dd`      | Kill process                      |
| `k` / `j` | Up / down                         |
| `gg` / `G`| Top / bottom                      |
| `f`       | Freeze updates                    |
| `Space`   | Toggle process tree               |

## Dust — `du` replacement

```bash
dust                # current dir
dust ~/projects     # specific path
dust -d 3           # depth 3
dust -n 10          # top 10 by size
dust -r             # reverse
dust -x             # same filesystem only
```

## Duf — `df` replacement

```bash
duf                 # all mounts
duf /home /var      # specific paths
duf --only local    # only local fs (skip tmpfs/devtmpfs)
duf --json          # JSON output for scripts
```

## Procs — `ps` replacement

```bash
procs                  # all processes (tree by default)
procs nvim             # filter by command
procs --watch          # live update
procs --tree           # tree view
procs --sortd cpu      # sort by CPU desc
procs --pager less     # paginate
```

## sd — `sed` replacement

```bash
sd 'old' 'new' file.txt              # replace in file
sd 'old' 'new' file.txt --preview    # dry run
echo 'hello world' | sd '(\w+) (\w+)' '$2 $1'   # capture groups
sd 'TODO' 'DONE' src/**/*.rs         # glob
```

## xh — modern curl

```bash
xh GET httpbin.org/json
xh POST httpbin.org/post name=fabio
xh https://api.github.com/users/oornnery
xh -d https://example.com/file.zip   # download
xh --auth user:pass GET api/secret
xh -j POST api/users name=fabio role=admin   # explicit JSON
```

## tldr — short man pages

```bash
tldr tar              # examples for tar
tldr --update         # refresh cache (~10MB; offline after)
tldr --list           # list all commands tldr knows
tldr -L pt_BR git     # Portuguese pages (where available)
```

## jless — JSON pager

```bash
cat file.json | jless
curl https://api.github.com/users/oornnery | jless

# Inside jless:
#   h/j/k/l    navigate
#   Space      page down
#   g / G      top / bottom
#   /pat       search
#   n / N      next / prev match
#   c          collapse
#   e          expand
#   q          quit
```

## Delta — git diff prettifier

Configured in `git/.gitconfig`:
```ini
[core]
  pager = delta
[delta]
  navigate = true
  line-numbers = true
  syntax-theme = base16
```

Just use git normally — delta hooks in transparently:
```bash
git diff
git log -p
git show HEAD
git blame file.ts
```

Inside delta pager: `n` next hunk, `N` previous hunk, `q` quit.

## Tips

| Tip                                          | Why                                           |
| -------------------------------------------- | --------------------------------------------- |
| Aliases gate on `command -v`                 | Config safe before `paru -S` finished         |
| Keep `sed` non-aliased                       | sd is great, but many scripts still want sed  |
| Run `tldr --update` after install            | Without cache, `tldr foo` errors              |
| `topgrade --dry-run` before running          | Shows what'll be touched                      |
| zsh-defer first plugin in OMZ                | Plugins after it can use `zsh-defer …`        |
| Forgit's `glo` for commit archaeology        | Faster than `git log -p` + Ctrl+F             |
