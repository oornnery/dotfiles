# GNU Stow

What `dots link` runs underneath. Each folder in `home/` is a package; its files are
linked into `$HOME` at the same path: `home/helix/.config/helix/config.toml` becomes
`~/.config/helix/config.toml`.

## Through dots

| Task | Command |
| ---- | ------- |
| Pick what is linked here | `dots link` |
| Link the packages of this machine | `dots link sync` (`-n` shows it) |
| Link one, unlink one | `dots link yazi`, `dots link -D yazi` |
| Put a config in the repo | `dots link add ~/.config/app` |
| What is linked | `dots link list` |

Files are linked one by one, never whole folders (`--no-folding`): what an app writes
next to its config stays out of the repo. A real file in the way is kept as
`.bak.<time>`.

## Stow itself

| Task | Command |
| ---- | ------- |
| Link | `stow --no-folding -d ~/dotfiles/home -t ~ zsh` |
| Dry run, verbose | add `-n -v` |
| Relink (after adding files) | `-R zsh` |
| Unlink | `-D zsh` |
| Take the files in the way into the repo | `--adopt zsh`, then look at `git diff` |
