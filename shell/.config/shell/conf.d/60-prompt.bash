# Wires the shared prompt (60-prompt.sh) into bash.
# Saves the start time and prints nothing. Reads PS1 because bash skips the
# arithmetic when the variable it expands is unset.
PS0='${PS1:$((_prompt_start=SECONDS,0)):0}'

__prompt() {
    local code=$? secs=0 clock pids jobs=0
    [ -n "${_prompt_start:-}" ] && secs=$(( SECONDS - _prompt_start ))
    unset _prompt_start
    printf -v clock '%(%H:%M)T' -1
    pids=$(jobs -p)
    [ -n "$pids" ] && jobs=$(wc -l <<< "$pids")
    _prompt_build "$code" "$secs" "$jobs" "$clock" $'\001' $'\002'
}

# First in the chain: it must read $?. direnv may have made this an array.
if [[ $(declare -p PROMPT_COMMAND 2>/dev/null) == 'declare -a'* ]]; then
    PROMPT_COMMAND=(__prompt "${PROMPT_COMMAND[@]}")
else
    # shellcheck disable=SC2178,SC2128  # a plain string on this branch
    PROMPT_COMMAND="__prompt${PROMPT_COMMAND:+; $PROMPT_COMMAND}"
fi
PS1='${_PROMPT_LINE}'
