# pet snippets: Ctrl-X Ctrl-R inserts the chosen command without running it.
(( $+commands[pet] )) || return 0
pet-select() {
    BUFFER=$(pet search --query "$LBUFFER" || true)
    CURSOR=$#BUFFER
    zle redisplay
}
zle -N pet-select
bindkey '^X^R' pet-select
