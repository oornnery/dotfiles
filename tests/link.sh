#!/usr/bin/env bash
# dots link: linking, backups of real files, and links left by moved files.
# shellcheck source=tests/lib.sh
. "$(dirname "$0")/lib.sh"

machine() { mkdir -p "$XDG_CONFIG_HOME/dots"; printf '%s\n' "$@" > "$XDG_CONFIG_HOME/dots/packages"; }

t_sync_links_the_packages_of_the_machine() {
    make_pkg zsh .zshrc; make_pkg vim .vimrc; machine zsh
    dots link sync
    is_link "$HOME/.zshrc" && [[ ! -e $HOME/.vimrc ]]
}

t_sync_links_files_inside_folders() {
    make_pkg helix .config/helix/config.toml; machine helix
    dots link sync
    is_link "$HOME/.config/helix/config.toml" && [[ ! -L $HOME/.config/helix ]]  # no folding
}

t_a_real_file_in_the_way_is_kept_as_a_backup() {
    make_pkg zsh .zshrc; machine zsh
    echo mine > "$HOME/.zshrc"
    dots link sync
    is_link "$HOME/.zshrc" && grep -q mine "$HOME"/.zshrc.bak.*
}

t_sync_removes_links_that_lead_nowhere() {
    make_pkg zsh .zshrc; machine zsh
    mkdir -p "$HOME/.config"
    ln -s "$DOTFILES_DIR/home/old/.config/gone" "$HOME/.config/gone"
    dots link sync
    [[ ! -L $HOME/.config/gone ]]
}

t_sync_leaves_other_broken_links_alone() {
    machine
    mkdir -p "$HOME/.config"; ln -s /nowhere "$HOME/.config/other"
    dots link sync
    [[ -L $HOME/.config/other ]]
}

t_link_adds_to_the_machine_and_D_removes() {
    make_pkg zsh .zshrc; machine
    dots link zsh && is_link "$HOME/.zshrc" && grep -qx zsh "$XDG_CONFIG_HOME/dots/packages" &&
    dots link -D zsh && [[ ! -e $HOME/.zshrc ]] && ! grep -qx zsh "$XDG_CONFIG_HOME/dots/packages"
}

t_add_moves_a_config_into_the_repo() {
    machine
    mkdir -p "$HOME/.config/foo"; echo x > "$HOME/.config/foo/foo.conf"
    dots link add "$HOME/.config/foo/foo.conf"
    [[ -f $DOTFILES_DIR/home/foo/.config/foo/foo.conf ]] && is_link "$HOME/.config/foo/foo.conf"
}

check
