#!/usr/bin/env bash
# The docs made from the code are up to date.
# shellcheck source=tests/lib.sh
. "$(dirname "$0")/lib.sh"

t_generated_docs_are_up_to_date() { "$REPO/docs/generate" --check; }

t_markdown_lists_the_desktop_commands_too() {
    has '`dots capture`' "$(DOTFILES_DIR=$REPO dots --markdown)"
}

check
