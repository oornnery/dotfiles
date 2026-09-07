#!/usr/bin/env bash
set -euo pipefail

# Link the three AI Stow packages. --migrate also archives the retired setup.
repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
target_dir="${DOTFILES_AI_TARGET:-$HOME}"
mode="${1:---dry-run}"
case "$mode" in
    --dry-run|--apply|--migrate) ;;
    *) echo "Usage: bash scripts/ai-setup.sh [--dry-run|--apply|--migrate]" >&2; exit 2 ;;
esac
[[ -d "$target_dir" && "$target_dir" == /* && "$target_dir" != / ]] || {
    echo "Target must be an existing absolute user directory, not /." >&2; exit 2;
}
target_dir="$(cd -- "$target_dir" && pwd)"
[[ "$target_dir" != "$repo_dir" ]] || { echo "Target cannot be the repository." >&2; exit 2; }
command -v stow >/dev/null || { echo "Install GNU Stow first." >&2; exit 1; }
backup_dir=""

archive() {
    local source="$1" label="$2" destination
    [[ -e "$source" || -L "$source" ]] || return 0
    if [[ "$mode" == --dry-run ]]; then
        printf 'Would archive: %s\n' "$source"
        return
    fi
    if [[ -z "$backup_dir" ]]; then
        mkdir -p "$target_dir/.local/state/dotfiles-ai"
        backup_dir="$(mktemp -d "$target_dir/.local/state/dotfiles-ai/backup.XXXXXXXX")"
        printf 'Recovery directory: %s\n' "$backup_dir"
    fi
    destination="$backup_dir/$label"
    mkdir -p "$(dirname -- "$destination")"
    mv -- "$source" "$destination"
    printf '%s\t%s\n' "$source" "$destination" >> "$backup_dir/moves.tsv"
}

if [[ "$mode" == --migrate || "$mode" == --dry-run ]]; then
    # Explicit retired skills only; preserve independently installed domain skills.
    for name in build spec backprop grill review research check caveman deepen \
        agent-harness arch building-agents cicd debugging design docs \
        frontend-design git quality verification; do
        archive "$target_dir/.agents/skills/$name" "skills/$name"
    done
    for name in opencode.slim opencode.omy opencode.pure; do
        archive "$repo_dir/$name" "repository/$name"
    done
    archive "$target_dir/.claude" "claude/config"
    archive "$target_dir/.claude.json" "claude/state.json"
    for name in .caveman-active .ponytail-active; do
        archive "$target_dir/.config/opencode/$name" "opencode/$name"
    done
fi

# Replace a previous standalone Impeccable install with this pinned Stow source.
impeccable="$target_dir/.agents/skills/impeccable"
if [[ -e "$impeccable" || -L "$impeccable" ]]; then
    if [[ "$(readlink -f "$impeccable/SKILL.md" || true)" != "$repo_dir/agents/.agents/skills/impeccable/SKILL.md" ]]; then
        archive "$impeccable" "skills/impeccable"
    fi
fi

# Older global OpenCode installs can override the shared skill by name.
for root in "$target_dir/.opencode/skills" "$target_dir/.config/opencode/skills"; do
    candidate="$root/impeccable"
    if [[ -e "$candidate" || -L "$candidate" ]]; then
        if [[ "$(readlink -f "$candidate/SKILL.md" || true)" != "$repo_dir/agents/.agents/skills/impeccable/SKILL.md" ]]; then
            archive "$candidate" "duplicates/${candidate#"$target_dir/"}"
        fi
    fi
done

# Stow cannot remove links whose source was deleted in a previous revision.
# Archive only broken links into this checkout, never another installation.
for root in "$target_dir/.agents/skills" "$target_dir/.codex/agents" "$target_dir/.config/opencode"; do
    [[ -d "$root" ]] || continue
    while IFS= read -r -d '' link; do
        resolved="$(readlink -m "$link")"
        if [[ "$resolved" == "$repo_dir/"* && ! -e "$link" ]]; then
            archive "$link" "stale-links/${link#"$target_dir/"}"
        fi
    done < <(find "$root" -type d -name node_modules -prune -o -type l -print0)
done

if [[ "$mode" == --dry-run ]]; then
    echo "Preview only. --migrate performs the archive above and applies links."
    echo "--apply only replaces old Impeccable/stale links and applies packages."
    exit 0
fi
stow --no-folding -d "$repo_dir" -t "$target_dir" -R agents codex opencode
printf 'Applied shared skills, Codex and OpenCode to %s\n' "$target_dir"
[[ -z "$backup_dir" ]] || printf 'Recover archived paths using %s/moves.tsv\n' "$backup_dir"
