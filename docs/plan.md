# Plan: reorganize dots

The repo grew to about 2800 lines of shell in 30 commands. It still works, but the
same code lives in several places, the same question has three answers, and every
new command starts from a copy of an old one. This plan keeps shell, and gives it one
shape, so the repo can keep growing and later take a command in another language.

Each phase is one commit, tested, and leaves everything working. Status: done, on the
branch `feat/reorg-dots`, in the order 0, 1, 2, 4, 5, 3, 6 (the move to `home/` came
before the machine file, so the machine file could use it).

What changed from the plan: the tests are plain bash (`tests/lib.sh`), not bats,
so they need nothing installed.

## What is wrong today

**Three sources of truth for "what this machine has".**

| Where | What it says | Versioned |
| ----- | ------------ | --------- |
| `~/.config/dots/packages` | Config packages linked here | no, local only |
| `packages/*.txt` | Packages installed, saved by `dots pkg save` | yes |
| `RECIPES` in `install` | Tools: their packages, configs and post steps | yes, inside a script |

A new machine cannot be rebuilt from the repo alone: the list of links is not in it.

**Repeated code.**

- The paths `DOTFILES`, `LIST` and the list reading are copied in `stow`, `doctor`
  and `status`; "is this file linked?" is written three times.
- Each command finds `_ui` its own way (`realpath "$0"`, `DOTS_LIB`, `here=`).
- `-h` prints hand-counted line ranges (`sed -n '6,12p'`), which break when the
  header changes; that already happened once.

**Commands that overlap.**

- `status`, `doctor`, `setup -n` and `pkg status/diff` all compare the machine
  with the repo, each in its own way.
- `dots install <tool>` and `dots pkg install` do different things with the same word.
- `dots --help` lists 22 commands in one flat list; 6 of them only exist on Hyprland,
  and 4 are internal helpers.

**No tests.** Only `bash -n` and shellcheck, run by hand.

## Where it goes

```text
dots status      what differs between this machine and the repo
dots apply       make this machine match the repo; -n shows what it would do
dots doctor      what is broken
```

One file says what a machine has; `status` reads it, `apply` makes it true, and
both reuse the same functions. Migrations cover the changes a file cannot describe.

## Phase 0: a safety net

Before moving anything, a way to know nothing broke.

- [x] Commit the pending work (`status`, `TODO.md`, the README map).
- [x] `tests/run`: `bash -n`, `zsh -n` and shellcheck on every script, then the bats
      tests. One command, also used by CI.
- [x] Tests for what the next phases touch: the dispatcher (`dots --help`,
      `--describe`, unknown command), `stow` against a temp `$HOME` and repo, `pkg`
      with fake managers, `status` on a temp git repo.
- [x] A GitHub Actions workflow on Arch (`archlinux` image) that runs `tests/run`.

## Phase 1: one library, one shape per command

- [x] `_lib`, the only file a command sources. It loads `_ui`, and holds:
  - the paths: `DOTFILES`, `CONFIG`, `STATE`, `CACHE` (XDG) and `HOST`;
  - the machine: `linked_packages`, `is_linked <file>`, `package_files <pkg>`;
  - `-h`/`--help` for free: it prints the comment block of the header, so no command
    counts lines again.
- [x] Every command takes the same shape:

  ```bash
  #!/usr/bin/env bash
  # dots:summary=One line
  # dots:group=machine
  # dots:args=[a | b]
  # dots:actions=a=What a does|b=What b does
  #
  # Longer help, printed by -h.
  set -uo pipefail
  . "$(dirname "$(realpath "$0")")/_lib"

  a() { ...; }
  b() { ...; }

  case "${1:-a}" in
      a) a ;;
      b) shift; b "$@" ;;
      *) die "unknown action: $1" ;;
  esac
  ```

- [x] `dots:group` in every header, and `dots --help` lists by group.
- [x] `stow`, `doctor` and `status` use `_lib` for the machine; the copies go away.
- [x] Internal helpers (`askpass`, `menu`, `notify`, `sudo`) are marked hidden, so
      they leave the list but keep working.

## Phase 2: the CLI

Few renames, only where a name hides what the command does or clashes with another.

| Group | Commands | Change |
| ----- | -------- | ------ |
| machine | `status`, `apply`, `doctor`, `migrate` | `setup` becomes `apply`; `migrate` is new |
| config | `link`, `edit`, `theme` | `stow` becomes `link`: it says what it does, not the tool |
| packages | `pkg`, `install`, `update` | `pkg install` becomes `pkg restore`, so `install` means one thing: a tool |
| use | `palette`, `help`, `tui`, `pane` | none |
| platform | `wsl`; on the desktop `hypr`, `capture`, `display`, `notifications`, `system`, `webapp` | none; grouped in the help |

- [x] Rename, and update every caller in the same PR: keybinds, docs, the palette,
      the motd line, Zellij, Yazi and Hyprland configs. One user, so no old names kept.
- [x] `dots apply` runs, in order: links, packages, theme, migrations. Each step is
      a function shared with `status`, which shows the same steps as pending.
- [x] `dots doctor` keeps only what is broken (missing tools, broken links, PATH,
      language servers); what is pending is `status`.
- [x] `bootstrap` at the repo root, for a new machine: install `git stow`, link
      `dots`, run `dots apply`. It replaces the three lines in the README.

## Phase 3: one file per machine

- [x] `machines/<host>`: which tools (recipes) and which extra config packages this
      machine has. It replaces `~/.config/dots/packages`, and it is versioned, so a
      machine can be rebuilt from the repo.

  ```text
  # machines/DESKTOP-T8DL9CB
  tools: zsh bash git helix zellij yazi television lazygit docker
  links: herdr mpv
  ```

- [x] The recipes leave the `install` script for `recipes` (a data file, same
      columns). A tool brings its packages, its config package and its `post_` step.
- [x] `packages/*.txt` stays as the snapshot of what is installed: `status` shows
      what is installed but is in no tool, so it can go into one.
- [x] `status` and `apply` read the machine file; `link` and `install` write it.
- [x] A machine with no file gets one from what is linked and installed now.

## Phase 4: migrations

For the changes a file cannot describe: rename a config, move a folder, drop a tool.

- [x] `migrations/NNN-name.sh`, run once each, in order. What ran is saved in
      `$STATE/migrations`.
- [x] `dots migrate` runs the pending ones; `migrate list` shows them; `migrate new
      <name>` writes the next file from a template.
- [x] `status` lists the pending ones and `apply` runs them.
- [x] Each one is small and safe to repeat, so a machine that is behind catches up.

## Phase 5: the repo layout

Today config packages and everything else share the top level. After:

```text
home/         config packages, linked into $HOME (zsh, helix, zellij...)
machines/     one file per machine
recipes       the tools
packages/     snapshots of what is installed
migrations/
themes/  windows/  docs/  ai/  self-hosted/  templates/
tests/
bootstrap  README.md  TODO.md
```

- [x] Move the config packages into `home/`, with `migrations/001-home.sh`: unlink
      from the old place, link from `home/`. It is also the first real test of
      migrations.
- [x] `dots link add` and `link`'s list of packages read `home/`.

## Phase 6: docs from the code

- [x] `dots help dots` and the commands table in the README come from the headers,
      so they never disagree with the code.
- [x] `tests/run` fails when the README table is out of date.

## Later: another language

The contract stays the same, so a command can be rewritten alone:

- a command is an executable in `~/.local/lib/dots/`;
- a script describes itself with the `# dots:` header; a binary prints the same lines
  for `--dots-meta`, and the dispatcher reads that instead;
- output follows `_ui`: ok, warn, err, section, note.

First candidate: `status`, which reads the most and would gain the most from running
its parts at the same time.

## Decisions

| Question | Decided |
| -------- | ------- |
| The machine file format | Plain `key: values` lines, read by `machine_get` in `_lib` |
| Renames | `setup` to `apply`, `stow` to `link`, `pkg install` to `pkg restore` |
| The Hyprland commands under `dots hypr <...>` | No: grouped as `desktop` in the help |
| `home/` | Yes, through migration 001 |
