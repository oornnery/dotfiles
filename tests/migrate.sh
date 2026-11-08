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

t_002_moves_the_list_into_the_machine_file() {
    mkdir -p "$XDG_CONFIG_HOME/dots" "$DOTFILES_DIR/migrations"
    printf '# old\nzsh\nshell\n' > "$XDG_CONFIG_HOME/dots/packages"
    printf 'shell|nothing|A tool with no such package|no-such-package|\n' > "$DOTFILES_DIR/recipes"
    cp "$REPO/migrations/002-machine-file.sh" "$DOTFILES_DIR/migrations/"
    dots migrate
    has 'links: zsh shell' "$(cat "$DOTFILES_DIR/machines/test")" && [[ ! -e $XDG_CONFIG_HOME/dots/packages ]]
}

t_status_shows_tools_not_set_up_here() {
    git init -q "$DOTFILES_DIR"
    printf 'tools: helix\nlinks:\n' > "$DOTFILES_DIR/machines/test"
    has '1 tool(s) of this machine not set up here' "$(dots status)"
}

t_status_leaves_out_state_files_beside_links() {
    git init -q "$DOTFILES_DIR"
    mkdir -p "$DOTFILES_DIR/home/foo/.config/foo" "$HOME/.config/foo"
    echo x > "$DOTFILES_DIR/home/foo/.config/foo/foo.conf"
    printf 'tools:\nlinks: foo\n' > "$DOTFILES_DIR/machines/test"
    ln -s "$DOTFILES_DIR/home/foo/.config/foo/foo.conf" "$HOME/.config/foo/foo.conf"
    touch "$HOME/.config/foo/.plugins.lock" "$HOME/.config/foo/new.conf"
    local out; out=$(dots status)
    has 'foo: ~/.config/foo/new.conf' "$out" && lacks plugins.lock "$out"
}

check
