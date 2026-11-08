# TODO

Ideas and improvements, roughly in order. What is already done lives in README.md.
The reorganization of dots, done, is in [docs/plan.md](docs/plan.md).

The goal: a system made from what I use, the way I use it. Clear commands that do one
thing (what Omarchy does for its author), with the freedom of the package managers I
like.

## Next

- [ ] One Node manager. vite-plus is in testing and clashes with fnm: both put a Node
      on the PATH. Pick one, drop the other from `shell/` and `packages/`.
- [ ] Review `ai/` (claude, codex, opencode, pi) and link what stays.
- [ ] `dots install hyprland` on the desktop, and test its commands for real.
- [ ] Decide the Windows Terminal `settings.json` with `dots wsl windows pull`.

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
- [ ] Review `machines/DESKTOP-T8DL9CB`: migration 002 guessed the tools from what
      is installed (openssh counts, though sshd may not run here).
- [ ] `dots theme` for Yazi icons, which keep fixed colors.
- [ ] `settings.dsc.winget` for Windows settings (dark mode, taskbar, developer mode).
- [ ] Rebuild `self-hosted/`.
