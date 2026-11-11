# Node moved from fnm to mise, which also keeps the versions of each project. On a
# machine with the node tool: install mise, link its config, install the Node it
# names, then remove fnm. The global npm packages come back with dots pkg restore.
set -euo pipefail

sed -n 's/^tools://p' "$MACHINE" | grep -qw node || exit 0   # no Node here

pacman -Q mise >/dev/null 2>&1 || dots pkg add mise
dots link mise
mise install
if pacman -Q fnm >/dev/null 2>&1; then dots pkg remove fnm; fi
echo "Node is now the one of mise. Open a new shell, then: dots pkg restore (npm packages)"
