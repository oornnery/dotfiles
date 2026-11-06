# Wires the shared prompt (60-prompt.sh) into zsh.
_prompt_preexec() { _prompt_start=$SECONDS }

_prompt_precmd() {
    local code=$? secs=0 format='%D{%H:%M}'
    [[ -n ${_prompt_start:-} ]] && secs=$(( SECONDS - _prompt_start ))
    unset _prompt_start
    _prompt_build "$code" "$secs" "${#jobstates}" "${(%)format}" '%{' '%}'
}

autoload -Uz add-zsh-hook
add-zsh-hook preexec _prompt_preexec
precmd_functions=(_prompt_precmd $precmd_functions)   # first: it must read $?
setopt PROMPT_SUBST
PROMPT='${_PROMPT_LINE}'
