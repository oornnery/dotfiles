#!/usr/bin/env bash
# The dispatcher: the list of commands, Tab completion and errors.
# shellcheck source=tests/lib.sh
. "$(dirname "$0")/lib.sh"

t_help_lists_by_group() {
    local out; out=$(dots --help)
    has machine "$out" && has status "$out" && has packages "$out"
}

t_help_hides_internal_commands() {
    local out; out=$(dots --help)
    lacks askpass "$out" && lacks menu "$out"
}

t_every_command_has_a_group() {
    local f
    for f in "$CLI"/.local/lib/dots/*; do
        [[ -x $f && ${f##*/} != _* ]] || continue
        grep -q '^# dots:hidden=true' "$f" && continue
        grep -q '^# dots:group=' "$f" || { echo "no group: ${f##*/}"; return 1; }
    done
}

t_describe_lists_commands() {
    has 'status:' "$(dots --describe)"
}

t_unknown_command_fails() {
    ! dots nope 2>/dev/null
}

t_command_help_comes_from_the_header() {
    local out; out=$(dots pkg -h)
    has 'dots pkg' "$out" && lacks 'dots:' "$out" && lacks shellcheck "$out"
}

check
