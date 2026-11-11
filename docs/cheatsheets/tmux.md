# tmux

Kept for servers and machines without Zellij: `dots link tmux` links its config
(`home/tmux/.tmux.conf`). Here Zellij is the daily one (`dots help zellij`).
The prefix is **`Ctrl a`**.

## Sessions

| Task | How |
| ---- | --- |
| New, named | `tmux new -s name` |
| List | `tmux ls`, inside: `prefix s` |
| Attach | `tmux attach -t name` (`tmux a` the last one) |
| Detach | `prefix d` |
| Rename | `prefix $` |
| Reload the config | `prefix r` |

## Windows and panes

| Key | Action |
| --- | ------ |
| `prefix c` | New window, in this folder |
| `prefix n` `prefix p` | Next, previous window (repeatable) |
| `prefix Tab` | The last window |
| `prefix 1`-`9` | That window (they start at 1) |
| `prefix \|` `prefix -` | Split side by side, top and bottom, in this folder |
| `Alt h` `j` `k` `l` | Move between panes, no prefix |
| `prefix H` `J` `K` `L` | Resize (repeatable) |
| `prefix z` | Zoom a pane |
| `prefix x` | Close the pane (asks) |
| `prefix ,` | Rename the window |

## Copy (vi keys)

| Key | Action |
| --- | ------ |
| `prefix [` | Copy mode; the mouse wheel enters it too |
| `v` `y` | Select, copy (to the system clipboard too) |
| `/` `n` | Search, next |
| `q` | Leave |

`Ctrl a Ctrl a` sends `Ctrl a` to the app inside. History: 100k lines.
