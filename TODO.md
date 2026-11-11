# TODO

Ideas and improvements, roughly in order. What is already done lives in README.md.
The reorganization of dots, done, is in [docs/plan.md](docs/plan.md).

The goal: a system made from what I use, the way I use it. Clear commands that do one
thing (what Omarchy does for its author), with the freedom of the package managers I
like.

## Next

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

- [ ] More tools in mise per project (Python, Go...), now that Node is there; uv
      keeps Python for now.
- [ ] `dots pkg` with nala-like output: a table with colors per manager, and the
      size of what installs.
- [ ] Groups of packages (base, dev, desktop), so a new machine picks a group.

## Windows

- [ ] Review `windows/winget/groups` (from the backup drive) and drop what is not used;
      WinScript and PC Manager are installed but in no group, to remove.
- [ ] The PowerShell scripts of the backup drive (`D:\Backup\win-run\scripts\win\run`):
      debloat, disable-ai, disable-onedrive, privacy, browsers, tweaks, dns, game-tweaks.
      They exist only on that drive. Into `windows/scripts/`, run by
      `dots wsl windows run <script>`; what is a registry value goes to
      `settings.dsc.winget` instead, which can be tested.
- [ ] `windows:` in the machine file (the groups of this machine), shown by dots status.

## Backup

- [ ] `dots backup` to the external drive, from the old `backup.sh` and
      `rsync-backup-excludes` (D:\Backup\wsl-backup): $HOME without caches, plus the
      package lists of every manager. First map what is worth keeping: projects,
      `~/.ssh` and secrets (encrypted?), configs not in the repo.
- [ ] How the repo describes a machine as it grows (files, folders, packages,
      services, backups): the `key: words` lines of machines/ for now; INI or Lua
      if it needs sections or logic.

## dots

- [ ] Review `machines/DESKTOP-T8DL9CB`: migration 002 guessed the tools from what
      is installed (openssh counts, though sshd may not run here).
- [ ] Rebuild `self-hosted/`.
