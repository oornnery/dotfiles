# TUIs

How to start each TUI and the few keys to get going. `Alt u` opens the ones
installed; `dots help packages` has their links. Most show every key on `?`.

Keys marked from the help screen of the TUI itself; the ones it could not open here
point to where the full list is.

## Every day

| TUI | Start | Keys |
| --- | ----- | ---- |
| lazygit | `lg` in a repo | `space` stage, `c` commit, `P` push, `p` pull, `?` all keys |
| yazi | `y` or `Alt e` | `Enter` open, `a` new, `r` rename, `d` trash, `.` hidden, `~` all keys |
| btop | `btop` | `m` menu, `f` filter processes, `k` kill, `q` quit |
| helix | `hx file` | `Space ?` every command (`dots help keys`) |
| zellij | `dev` or `zellij` | `Ctrl p` panes, `Ctrl t` tabs, `Alt ?` help (`dots help zellij`) |

## Git

| TUI | Start | Keys |
| --- | ----- | ---- |
| serie | `serie` in a repo | `j` `k` move, `Enter` commit details, `Tab` refs, `/` search, `n` `N` next match, `?` or `F1` help, `q` quit |

## System and containers

| TUI | Start | Keys |
| --- | ----- | ---- |
| systemctl-tui | `systemctl-tui` | `j` `k` move, `/` or `Ctrl f` search, `Enter` the commands of a unit (start, stop, restart), `f` filter, `Ctrl r` reverse logs, `?` help, `Ctrl q` quit |
| lazyjournal | `lazyjournal` | `Tab` next window, `Enter` load a log, `/` filter, `Left` `Right` other lists, `[` `]` how many lines, `F1` help |
| oxker | `oxker` | `Tab` next panel, `Enter` start, stop, restart..., `e` shell in the container, `/` filter, `#` search logs, `s` save logs, `h` help, `q` quit |
| lazydocker | `ld` | `[` `]` tabs, `Enter` focus, `d` remove, `r` restart, `?` help |

## Network

| TUI | Start | Keys |
| --- | ----- | ---- |
| trippy | `trip 1.1.1.1` | `h` help, `5` all keys, `s` settings, `q` quit |
| termshark | `termshark -i eth0`, or `termshark -r file.pcap` | `/` display filter, `Tab` panes, `?` help, `q` quit. Capturing needs the `wireshark` group (`dots install tui-network`) |
| lazyssh | `lazyssh` (reads `~/.ssh/config`) | `Enter` connect, `a` add, `e` edit, `d` delete, `c` copy the ssh command, `g` ping, `f` port forward, `/` search, `q` quit |

## Data and APIs

| TUI | Start | Keys |
| --- | ----- | ---- |
| posting | `posting` | `Ctrl l` the URL (a curl command pasted there fills the request), `Ctrl j` send, `Ctrl t` method, `Ctrl s` save, `Ctrl n` new, `Ctrl o` jump to any part, `Ctrl p` every command, `F1` help |
| lazysql | `lazysql` | `n` new connection, `Enter` connect, `H` `L` tree and table, `Ctrl e` SQL editor, `Ctrl r` run it, `Ctrl p` search, `?` help |
| fx | `fx file.json` or `curl ... \| fx` | `l` `h` expand, collapse, `e` `E` expand, collapse all, `/` search, `n` `N` next match, `y` copy, `?` help |
| tabiew | `tw file.csv` (also tsv, parquet, json, sqlite, excel) | `h` `j` `k` `l` move, `q` SQL query, `f` filter, `/` search, `t` tabs, `:` every command, `Q` quit |
| epycell | `epycell notebook.ipynb` | Jupyter in the terminal |

## Notes and tasks

| TUI | Start | Keys |
| --- | ----- | ---- |
| taskwarrior-tui | `taskwarrior-tui` | `a` add, `d` done, `e` edit, `/` filter, `[` `]` other views, `?` help |
| task | `task add Buy milk due:fri`, `task`, `task 3 done` | the command line under taskwarrior-tui |
| dooit | `dooit` | `Tab` workspaces and todos, `a` add, `A` add inside, `i` edit, `d` due date, `c` done, `xx` remove, `/` search, `?` help |
| calcure | `calcure` | `Space` calendar or tasks, `a` add, `d` done, `x` delete, `n` `p` next and previous month, `?` help, `q` quit |
| zk | `zk new --title "An idea"`, `zk edit --interactive`, `zk list` | notes in `~/notes`, picked with fzf |
| nb | `nb add`, `nb`, `nb edit 1`, `nb search word` | notes, bookmarks and to-dos, in git |

## News

| TUI | Start | Keys |
| --- | ----- | ---- |
| circumflex | `clx` | `Enter` comments, `Space` the article (reader mode), `o` article in the browser, `c` comments in the browser, `Tab` next category, `i` all keys, `q` quit |
| eilmeldung | `eilmeldung`; the first time pick Local, then `:importopml ~/.config/eilmeldung/feeds.opml` | `s` sync, `j` `k` move, `h` `l` panels, `o` open in the browser, `r` `u` read, unread, `m` star, `/` search, `?` all keys |

## Dev and fun

| TUI | Start | Keys |
| --- | ----- | ---- |
| dekit | `dekit "npm run dev" "npm run worker"` | one pane per command; its keys are in its help ([pvolok/dekit](https://github.com/pvolok/dekit)) |
| presenterm | `presenterm slides.md` (`docs/slides/dots.md`) | `Right` `Left` next and previous slide; the rest in [its docs](https://github.com/mfontanini/presenterm) |
| spotify_player | `spotify_player` (Spotify Premium, logs in the first time) | `Space` play and pause, `?` every command |
| ttyper | `ttyper` | type the text; `Esc` quits |

## Desktop

| TUI | Start | Keys |
| --- | ----- | ---- |
| wiremix | `wiremix` | PipeWire audio: outputs, inputs, volume |
| impala | `impala` | Wi-Fi through iwd |
| bluetui | `bluetui` | Bluetooth devices |

These run on the desktop (Hyprland), not on WSL; their keys are in their help.
