# Tab completion for dots: commands, then the actions of each command.
_dots() {
    local cur=${COMP_WORDS[COMP_CWORD]}
    case $COMP_CWORD in
        1) mapfile -t COMPREPLY < <(compgen -W "$(dots --commands)" -- "$cur") ;;
        2) mapfile -t COMPREPLY < <(compgen -W "$(dots --actions "${COMP_WORDS[1]}")" -- "$cur") ;;
    esac
}
complete -o default -F _dots dots
