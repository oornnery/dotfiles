# The config packages moved from the top of the repo into home/. The links made
# before point to the old place and lead nowhere: remove them, then link the same
# packages from home/. dots itself is one of them, so run it from the repo:
#   ~/dotfiles/home/dots/.local/bin/dots migrate
set -euo pipefail

repo=$(realpath "$DOTFILES")

stale() {  # broken links in the places the packages link to
    find "$HOME/.config" "$HOME/.local/bin" "$HOME/.local/lib" "$HOME/.local/share" "$HOME/.atuin" -xtype l 2>/dev/null || true
    find "$HOME" -maxdepth 1 -xtype l 2>/dev/null || true
}

while IFS= read -r link; do
    target=$(readlink "$link")
    [[ $target == /* ]] || target=$(dirname "$link")/$target
    [[ $(realpath -m "$target") == "$repo"/* ]] || continue  # not ours
    rm "$link" && echo "removed ${link/#$HOME/\~}"
done < <(stale)

# The same packages as before, now from home/.
while IFS= read -r pkg; do
    [[ -d $PKGS/$pkg ]] && stow --no-folding -d "$PKGS" -t "$HOME" -R "$pkg" && echo "linked $pkg"
done < <(sed -e 's/#.*//' -e 's/[[:space:]]//g' "$LIST" 2>/dev/null | grep -v '^$')
