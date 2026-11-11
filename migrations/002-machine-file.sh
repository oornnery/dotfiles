# What a machine links moved from ~/.config/dots/packages, which only this machine
# saw, to machines/<host> in the repo, next to the tools set up here. The tools are
# the recipes with every package installed and every config package linked; they
# count as set up, so dots apply does not run their steps again.
set -euo pipefail

[[ -f $MACHINE ]] && exit 0   # already there

links=$(sed -e 's/#.*//' -e 's/[[:space:]]//g' "$LIST" 2>/dev/null | grep -v '^$' || true)
tools=$(grep -v '^#' "$DOTFILES/recipes" | while IFS='|' read -r _ name _ pkgs configs; do
    [[ -n $name ]] || continue
    # shellcheck disable=SC2086  # one word per package
    pacman -Q $pkgs >/dev/null 2>&1 || continue
    for c in $configs; do grep -qx "$c" <<< "$links" || continue 2; done
    echo "$name"
done)

mkdir -p "${MACHINE%/*}" "$STATE"
{
    echo "# ${MACHINE##*/}: what dots apply sets up on this machine."
    echo "# tools: dots install <name>    links: dots link <package>"
    echo "tools: $(paste -sd' ' <<< "$tools")"
    echo "links: $(paste -sd' ' <<< "$links")"
} > "$MACHINE"
sort -u <(cat "$STATE/tools" 2>/dev/null) <(printf '%s\n' "$tools") | grep -v '^$' > "$STATE/tools.new" || true
mv "$STATE/tools.new" "$STATE/tools"
rm -f "$LIST"
echo "wrote ${MACHINE#"$DOTFILES"/}"
