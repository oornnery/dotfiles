# Tab completion for dots: commands, then the actions of each command.
# Bash shows no descriptions, so only the words before the colon are used.
_dots() {
    local cur=${COMP_WORDS[COMP_CWORD]} words
    case $COMP_CWORD in
        1) words=$(dots --describe | cut -d: -f1) ;;
        2) words=$(dots --describe "${COMP_WORDS[1]}" | cut -d: -f1) ;;
        *) return ;;
    esac
    mapfile -t COMPREPLY < <(compgen -W "$words" -- "$cur")
}
complete -o default -F _dots dots
