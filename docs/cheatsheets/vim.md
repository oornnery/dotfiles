# Vim Cheatsheet

Plain Vim — used as the emergency editor (sudoedit, recovery TTY, SSH on hosts
without neovim). Neovim is the daily driver. Config in `~/.vimrc`.

## Leader / save & quit

| Bind         | Action                  |
| ------------ | ----------------------- |
| `,`          | Leader key              |
| `,w`         | `:w` (save)             |
| `,q`         | `:q` (quit)             |
| `,x`         | `:x` (save + quit)      |
| `<Esc><Esc>` | Clear search highlight  |

## Modes

| Key       | Mode                      |
| --------- | ------------------------- |
| `i` / `a` | Insert (before / after)   |
| `I` / `A` | Insert (line start / end) |
| `o` / `O` | Open line below / above   |
| `v`       | Visual (char)             |
| `V`       | Visual line               |
| `Ctrl-v`  | Visual block              |
| `:`       | Command-line              |
| `R`       | Replace mode              |
| `Esc`     | Back to normal            |

## Motion

| Key        | Action                            |
| ---------- | --------------------------------- |
| `h j k l`  | Left / down / up / right          |
| `w` / `b`  | Word forward / back               |
| `W` / `B`  | WORD (whitespace-separated)       |
| `e` / `ge` | End of word forward / back        |
| `0` / `^`  | Line start / first non-blank      |
| `$`        | Line end                          |
| `gg` / `G` | File top / bottom                 |
| `{` / `}`  | Paragraph up / down               |
| `%`        | Match `()`, `[]`, `{}`            |
| `f<c>`     | Find `<c>` forward                |
| `F<c>`     | Find `<c>` backward               |
| `t<c>`     | Till `<c>` forward                |
| `;` / `,`  | Repeat last `f`/`t` fwd / back    |
| `n` / `N`  | Next / previous search match      |
| `*` / `#`  | Search word under cursor fwd/back |

## Editing

| Key            | Action                       |
| -------------- | ---------------------------- |
| `x`            | Delete char under cursor     |
| `dd`           | Delete line                  |
| `D`            | Delete to end of line        |
| `d<motion>`    | Delete over motion           |
| `cc` / `C`     | Change line / to end of line |
| `c<motion>`    | Change over motion           |
| `yy`           | Yank (copy) line             |
| `y<motion>`    | Yank over motion             |
| `p` / `P`      | Paste after / before         |
| `u` / `Ctrl-r` | Undo / redo                  |
| `.`            | Repeat last change           |
| `>>` / `<<`    | Indent / dedent line         |
| `J`            | Join line with next          |
| `~`            | Toggle case                  |

## Text objects (combine with `d`/`c`/`y`/`v`)

| Object | Means                            |
| ------ | -------------------------------- |
| `iw`   | Inner word                       |
| `aw`   | A word (incl. surrounding space) |
| `i"`   | Inside double quotes             |
| `a"`   | Including quotes                 |
| `i(`   | Inside parens (also `i)`, `ib`)  |
| `i{`   | Inside braces (also `i}`, `iB`)  |
| `it`   | Inside HTML/XML tag              |
| `ip`   | Inner paragraph                  |

Example: `ci"` → change text inside quotes. `dap` → delete paragraph.

## Search / replace

| Cmd                  | Action                                |
| -------------------- | ------------------------------------- |
| `/pat`               | Search forward                        |
| `?pat`               | Search backward                       |
| `:%s/old/new/g`      | Replace globally                      |
| `:%s/old/new/gc`     | Replace with confirmation             |
| `:%s/\<word\>/new/g` | Replace whole word only               |
| `:g/pat/d`           | Delete all lines matching `pat`       |
| `:v/pat/d`           | Delete all lines NOT matching `pat`   |

## Windows / buffers / tabs

| Cmd / Bind       | Action                        |
| ---------------- | ----------------------------- |
| `:e <file>`      | Edit file in current window   |
| `:sp <file>`     | Horizontal split              |
| `:vsp <file>`    | Vertical split                |
| `Ctrl-w h/j/k/l` | Focus pane left/down/up/right |
| `Ctrl-w =`       | Equalize pane sizes           |
| `Ctrl-w q`       | Close pane                    |
| `:bn` / `:bp`    | Next / previous buffer        |
| `:ls`            | List buffers                  |
| `:b <n>`         | Switch to buffer `n`          |
| `:bd`            | Delete buffer                 |
| `:tabnew`        | New tab                       |
| `gt` / `gT`      | Next / previous tab           |

## Marks & registers

| Key               | Action                        |
| ----------------- | ----------------------------- |
| `m<a-z>`          | Set mark `<a-z>` (file-local) |
| `m<A-Z>`          | Set mark (cross-file)         |
| `` `a ``          | Jump to mark `a`              |
| `'a`              | Jump to mark `a`'s line start |
| `"<reg>y`         | Yank into register `<reg>`    |
| `"<reg>p`         | Paste from register `<reg>`   |
| `"+y`             | Yank to system clipboard      |
| `"+p`             | Paste from system clipboard   |
| `:reg`            | Show all registers            |

## Macros

| Key               | Action                     |
| ----------------- | -------------------------- |
| `q<a-z>` then `q` | Record macro into register |
| `@<a-z>`          | Replay macro               |
| `@@`              | Replay last macro          |
| `<n>@<a-z>`       | Replay `n` times           |

## Tips

| Tip                                  | Why it helps                  |
| ------------------------------------ | ----------------------------- |
| Leader is `,` (close to right hand)  | Faster than default `\`       |
| `<Esc><Esc>` clears `hlsearch`       | Visual quiet after `/`        |
| `"+y` and `"+p` for system clipboard | Cross-app copy/paste          |
| Text objects (`ci"`, `dap`)          | Less precise cursoring needed |
| `.` repeats last change              | Many edits become one-key     |
