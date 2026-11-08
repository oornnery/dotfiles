#!/usr/bin/env bash
# dots migrate: each migration runs once, in order, and a failure stops the rest.
# shellcheck source=tests/lib.sh
. "$(dirname "$0")/lib.sh"

migration() { mkdir -p "$DOTFILES_DIR/migrations"; printf '%s\n' "$2" > "$DOTFILES_DIR/migrations/$1.sh"; }

t_runs_each_migration_once_in_order() {
    migration 001-a 'echo a >> "$HOME/ran"'
    migration 002-b 'echo b >> "$HOME/ran"'
    dots migrate && dots migrate
    [[ $(paste -sd' ' "$HOME/ran") == 'a b' ]]
}

t_a_failure_stops_the_next_ones() {
    migration 001-a 'exit 1'
    migration 002-b 'echo b >> "$HOME/ran"'
    ! dots migrate && [[ ! -e $HOME/ran ]] && has 001-a "$(dots migrate list)"
}

t_done_marks_all_as_ran() {
    migration 001-a 'echo a >> "$HOME/ran"'
    dots migrate --done && dots migrate
    [[ ! -e $HOME/ran ]]
}

t_status_shows_the_pending_ones() {
    git init -q "$DOTFILES_DIR"
    migration 001-a 'true'
    has '1 migration(s) not run here' "$(dots status)"
}

check
