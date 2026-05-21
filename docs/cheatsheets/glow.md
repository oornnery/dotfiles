# Glow + Less Cheatsheet

Markdown rendering for the terminal. In this repo, `dots-cheatsheet` pipes glow
through `less -R` so search (`/`) and ANSI colors both work.

## Glow

| Command                       | What it does                          |
| ----------------------------- | ------------------------------------- |
| `glow file.md`                | Render to stdout                      |
| `glow -p file.md`             | Internal mini-pager (no search)       |
| `glow -s dark file.md`        | Force dark theme                      |
| `glow -s light file.md`       | Light theme                           |
| `glow -w 90 file.md`          | Wrap at 90 columns                    |
| `glow .`                      | List markdown files in dir            |
| `glow -l`                     | TUI browser of `~/.glow/`             |
| `glow github.com/u/r`         | Render GitHub repo README             |

## Glow + less (recommended pattern)

```bash
glow -s dark -w 90 file.md | less -R -i --mouse --use-color
```

The `dots-cheatsheet` script uses this exact pipeline because `glow -p` has a
limited internal pager that can't search through ANSI codes properly.

## Less navigation

| Key            | Action                              |
| -------------- | ----------------------------------- |
| `Space` / `f`  | Page down                           |
| `b`            | Page up                             |
| `d` / `u`      | Half-page down / up                 |
| `j` / `k`      | Line down / up                      |
| `g` / `G`      | Top / bottom of file                |
| `<n>g`         | Go to line `n`                      |
| `/<text>`      | Search forward                      |
| `?<text>`      | Search backward                     |
| `n` / `N`      | Next / previous match               |
| `&<pat>`       | Show ONLY lines matching pat        |
| `q`            | Quit                                |
| `h`            | Help (full keybind list)            |
| `=`            | Show file info (line, byte count)   |
| `Ctrl + g`     | Same — file position                |
| `m<letter>`    | Set mark                            |
| `'<letter>`    | Jump to mark                        |
| `''`           | Jump to previous position           |
| `v`            | Open file in `$EDITOR` at this line |
| `Esc-u`        | Clear search highlight              |

## Less flags (used in dots-cheatsheet)

| Flag           | Effect                                        |
| -------------- | --------------------------------------------- |
| `-R`           | Pass ANSI escape codes through (keep colors)  |
| `-i`           | Case-insensitive search (until uppercase used)|
| `-I`           | Always case-insensitive                       |
| `--mouse`      | Scroll with mouse wheel                       |
| `--use-color`  | Color the less prompt itself                  |
| `-F`           | Quit if content fits on one screen            |
| `-S`           | Truncate long lines (don't wrap)              |
| `-N`           | Show line numbers                             |
| `-X`           | Don't clear screen on exit                    |
| `-+S` / `-+N`  | Toggle wrapping / line numbers at runtime     |

## Recipes

```bash
# Render a doc with search-friendly pager
glow -s dark -w 90 README.md | less -R -i --mouse

# Same but stay on screen after quit (-X) and start at first occurrence (+/)
glow README.md | less -R -X +/Installation

# Compare two markdown files side by side (kind of)
diff <(glow a.md) <(glow b.md) | less -R

# Pipe a man page through glow? No — use bat:
man tmux | col -bx | bat -l man --paging=always

# Read a remote README
curl -s https://raw.githubusercontent.com/u/r/main/README.md | glow -s dark -p
```

## dots-cheatsheet integration

The viewer is picked by `$DOTS_MD_VIEWER` (default: `auto` → glow → rich → bat):

| Value  | Renderer                                              |
| ------ | ----------------------------------------------------- |
| `glow` | glow → less -R (best: rendered headers, tables, search) |
| `bat`  | bat with `.md` syntax (shows raw source w/ highlighting) |
| `rich` | `rich-cli` markdown (AUR — cyan/orange palette)         |
| `auto` | First available of glow → rich → bat                    |

```bash
# Override for one call
DOTS_MD_VIEWER=bat dots-cheatsheet
```

## Tips

| Tip                                              | Why it helps                          |
| ------------------------------------------------ | ------------------------------------- |
| Use `less -R` over `glow -p`                     | Search actually works through ANSI    |
| `-i` makes `/foo` match `Foo` too                | Less typing for ad-hoc searches       |
| `v` in less opens at the same line in `$EDITOR`  | Read → edit without leaving           |
| `glow -w 90` matches the floating-md window      | No mid-table line wrap                |
| `bat` viewer shows markup (good for editing)     | When you want to see the raw `**bold**` |
