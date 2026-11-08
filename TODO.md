# TODO

Ideas and improvements, roughly in order. What is already done lives in README.md.
The reorganization of dots is planned in [docs/plan.md](docs/plan.md).

The goal: a system made from what I use, the way I use it. Clear commands that do one
thing (what Omarchy does for its author), with the freedom of the package managers I
like.

## Next

- [ ] One Node manager. vite-plus is in testing and clashes with fnm: both put a Node
      on the PATH. Pick one, drop the other from `shell/` and `packages/`.
- [ ] Review `ai/` (claude, codex, opencode, pi) and link what stays.
- [ ] `dots install hyprland` on the desktop, and test its commands for real.
- [ ] Decide the Windows Terminal `settings.json` with `dots wsl windows pull`.
- [ ] Alt keys in zsh as widgets, so they do not type after what is on the line.

## Migrations

Changes that one machine needs once (rename a config, move a folder, drop a package).

- [ ] `dots migrate`: numbered scripts in `migrations/`, run once each, in order;
      what ran is saved in `~/.local/state/dots/migrations`. `dots status` lists the
      ones not run yet.
- [ ] Each one safe to repeat and small, so a machine that is behind can catch up in one go.

## Packages

What I like in each one:

- pacman and paru: fast, simple, and the AUR has everything.
- apx: packages of other distros in containers, without touching the system.
- Nix: an isolated environment for one project or one test, then it is gone.
- nala: colored output that is easy to read.

Ideas:

- [ ] `dots try <pkg>`: run a package in a throwaway environment (distrobox, or
      `nix shell` if Nix ever comes), without installing it on the system.
- [ ] Environments per project: a file in the repo lists its tools, and entering the
      folder makes them available (direnv is installed; mise or Nix could fill it).
- [ ] `dots pkg` with nala-like output: a table with colors per manager, and the
      size of what installs.
- [ ] Groups of packages (base, dev, desktop), so a new machine picks a group.

## dots

- [ ] `dots status` on a timer, or in the prompt, as a small count.
- [ ] `dots theme` for Yazi icons, which keep fixed colors.
- [ ] `settings.dsc.winget` for Windows settings (dark mode, taskbar, developer mode).
- [ ] Rebuild `self-hosted/`.
