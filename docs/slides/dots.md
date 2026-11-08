---
title: dots
sub_title: A system made from what I use, the way I use it
author: oornnery
---

<!-- Run: presenterm docs/slides/dots.md   (arrows move, q quits) -->

The idea
---

* One repo describes the machine: configs, packages, tools, folders
<!-- pause -->
* One command keeps the machine and the repo the same: `dots`
<!-- pause -->
* Plain shell scripts that run; every step safe to repeat
<!-- pause -->
* Arch on WSL today, Arch with Hyprland on the desktop later

<!-- end_slide -->

Three commands
---

```bash
dots status    # what is pending: commits, links, tools, packages
dots apply     # make this machine match its file
dots doctor    # what is broken
```

<!-- pause -->

The prompt shows the pending count; `dots apply -n` shows what would change.

<!-- end_slide -->

A machine is a file
---

```text
# machines/DESKTOP-T8DL9CB
tools: zsh helix zellij yazi docker node ...
links: dots shell zsh helix zellij ...
folders: labs projects scripts services
```

<!-- column_layout: [1, 1] -->

<!-- column: 0 -->

**tools**: `dots install <name>`

packages, config, post step

<!-- column: 1 -->

**links**: `dots link <package>`

`home/<package>` into `$HOME`

<!-- reset_layout -->

<!-- end_slide -->

What changes once
---

```bash
dots migrate        # migrations/NNN-name.sh, once per machine
```

| Migration | What it did |
| --- | --- |
| 001-home | config packages moved into `home/` |
| 002-machine-file | the list of links became `machines/<host>` |
| 003-mise | Node moved from fnm to mise |

<!-- end_slide -->

Everyday keys
---

| Key | Opens |
| --- | --- |
| `Alt /` | the palette: everything, with fzf |
| `Alt ?` | help pages |
| `Alt u` | TUIs |
| `Alt e` | yazi |
| `Alt g` | lazygit |

<!-- pause -->

Same keys in the shell and in Zellij.

<!-- end_slide -->

Next
---

* Windows: packages by group, settings, scripts
* `dots backup` to the external drive
* Back to Arch on the desktop: `dots install hyprland`

<!-- end_slide -->

<!-- jump_to_middle -->

Thanks
---
