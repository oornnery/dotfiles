# Pet Cheatsheet

Snippet manager — [knqyf263/pet](https://github.com/knqyf263/pet). Arch: AUR
`pet-bin`, installed by `scripts/arch/dev/cli-tools.sh` when `paru` is present.

| File     | Path                         | Versioned           |
| -------- | ---------------------------- | ------------------- |
| Config   | `~/.config/pet/pet.toml`     | yes, `pet/` package |
| Snippets | `~/.config/pet/snippet.toml` | yes, `pet/` package |

Both are symlinks into this repo, so `pet new` writes straight into Git — commit
the snippet file afterwards. `snippetfile` and `snippetdirs` are deliberately
**not** set: pet resolves them as absolute paths, which would break the second
machine and start writing untracked snippets.

## Keys

| Bind            | Action                                                             |
| --------------- | ------------------------------------------------------------------ |
| `Ctrl+X Ctrl+R` | Insert the selected snippet at the cursor (editable, not executed) |
| `Esc`           | Abort the picker; the command line stays as it was                 |

Upstream docs bind `Ctrl+S` and disable flow control with `stty -ixon`. This setup
uses the `Ctrl-X` prefix instead so `Ctrl+S` keeps its shell job.

## Commands

```bash
pet search                    # fzf picker; prints the chosen command
pet search -t youtube         # tag filter (comma separated values)
pet search -q docker          # pre-filled query; --color and --raw also exist
pet new                       # register a snippet (`pet new COMMAND` works too)
pet new -t                    # prompt for tags as well; -m multiline, -e use editor
pet list --oneline            # one line per snippet; -t/--tags to filter
pet clip                      # copy the selection to the clipboard (--command, -d)
pet exec                      # run the selected snippet (-s silent)
pet edit                      # open snippet.toml in nvim
pet sync                      # gist / GitLab sync (unused: Git is the sync here)
pet configure                 # open pet.toml in $EDITOR
```

## Snippet file format

```toml
[[snippets]]
  description = "Which package owns a file or command"
  command = "pacman -Qo $(command -v git) /etc/pacman.conf"
  tag = "arch pacman"
  output = ""
```

`output` is optional captured text — keep it empty for commands whose output is
noise. `sortby = "-recency"` (this config) puts the most recently used first.
Tags are space separated, so `pet search -t yts,youtube` matches either.

## Workflow: video → transcript → summary

`dots yt <url>` runs yt-dlp through `uvx`, converts subtitles to plain text and
asks `pi` for a structured summary. The surface lives in the snippet file under
the `yts` tag:

```bash
dots yt https://www.youtube.com/watch?v=VIDEO_ID      # transcript + summary
dots yt --langs en --no-summary <url>                 # transcript only
dots yt --vault <url>                                 # also copy the note to the vault
dots yt --from-file clip.vtt                          # offline, no download
```

Outputs land in `$XDG_DATA_HOME/yt/<video-id>/` as `<id>.txt`, `<id>.md` and
`<id>.json` metadata. See [Shell tools](../applications/03-shell-tools.md).

## See also

- [Zsh cheatsheet](zsh.md) — line editor bindings
- [TUIs](../applications/05-tuis.md) — fzf, lazygit, lazydocker
