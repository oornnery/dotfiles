# Prompt shared by zsh and bash; 60-prompt.zsh and 60-prompt.bash wire it in.
# Terminal colors only, so it follows `dots theme`.
#
#   [box] oornnery ~/dotfiles main +*? ↑1↓2 ≡1     ✗INT  12s  ⚙2  py:app  node 26  14:32
#   ❯
#
# Left, who and where: container, user (@host on SSH), folder, git.
# Git: + staged, * changed, ? untracked, ! conflict, ↑ ahead, ↓ behind, ≡ stashes.
# Right, what happened and with what: error, time from 3s, background jobs,
# Python venv, Node in a folder with package.json, clock. When the line does not
# fit, they leave from the right; the error goes last.

_prompt_add() {  # _prompt_add <color> <text> [text for the prompt, if it differs]
    out+="$o${e}${1}m$c${3:-$2}$r"
    plain+=$2
}

_prompt_right() {  # same as _prompt_add, for the right side
    right+="  $o${e}${1}m$c${3:-$2}$r"
    rplain+="  $2"
}

_prompt_node() {  # major Node version here; asks node once per folder
    [ -f package.json ] && command -v node >/dev/null 2>&1 || { _PROMPT_NODE=''; _PROMPT_NODE_DIR=''; return; }
    [ "${_PROMPT_NODE_DIR:-}" = "$PWD" ] && return
    _PROMPT_NODE_DIR=$PWD
    _PROMPT_NODE=$(command node --version 2>/dev/null)
    _PROMPT_NODE=${_PROMPT_NODE#v}
    _PROMPT_NODE=${_PROMPT_NODE%%.*}
}

_prompt_build() {  # _prompt_build <exit code> <seconds> <jobs> <clock> <open> <close>
    local code=$1 secs=$2 jobs=$3 clock=$4 o=$5 c=$6 e=$'\033[' r
    local dir safe_dir branch='' safe_branch oid='' ahead=0 behind=0 line ab xy venv arrow=2
    local staged='' changed='' untracked='' conflict='' arrows='' out='' plain=''
    local time='' level=6 right rplain pad=0 spaces='' max stash=0 status_text='' safe_venv=''
    r="$o${e}0m$c"

    case $PWD in
        "$HOME")   dir='~' ;;
        "$HOME"/*) dir="~${PWD#"$HOME"}" ;;
        *)         dir=$PWD ;;
    esac

    while IFS= read -r line; do
        case $line in
            '# branch.oid '*)  oid=${line#\# branch.oid } ;;
            '# branch.head '*) branch=${line#\# branch.head } ;;
            '# branch.ab '*)   ab=${line#\# branch.ab +}; ahead=${ab%% *}; behind=${ab##*-} ;;
            '# stash '*)       stash=${line#\# stash } ;;
            '? '*) untracked='?' ;;
            'u '*) conflict='!' ;;
            '1 '*|'2 '*)
                xy=${line#? }; xy=${xy%% *}
                [ "${xy%?}" = . ] || staged='+'
                [ "${xy#?}" = . ] || changed='*' ;;
        esac
    done < <(command git --no-optional-locks status --porcelain=v2 --branch --show-stash 2>/dev/null)
    [ "$branch" = '(detached)' ] && branch=${oid%"${oid#???????}"}

    safe_dir=$dir; safe_branch=$branch
    if [ -n "${ZSH_VERSION:-}" ]; then  # % is special in zsh prompts
        safe_dir=${dir//\%/%%}; safe_branch=${branch//\%/%%}
    fi

    # Left side
    if [ -n "${CONTAINER_ID:-}" ]; then _prompt_add 33 "[$CONTAINER_ID]"; out+=' '; plain+=' '; fi
    if [ -n "${SSH_CONNECTION:-}" ]; then
        _prompt_add 32 "${USER:-}@${HOSTNAME:-${HOST:-}}"
    else
        _prompt_add 32 "${USER:-}"
    fi
    out+=' '; plain+=' '
    _prompt_add 36 "$dir" "$safe_dir"

    if [ -n "$branch" ]; then
        out+=' '; plain+=' '
        _prompt_add 35 "$branch" "$safe_branch"
        if [ -n "$staged$changed$untracked$conflict" ]; then
            out+=' '; plain+=' '
            _prompt_add 33 "$staged$changed$untracked$conflict"
        fi
        [ "$ahead" != 0 ] && arrows+="↑$ahead"
        [ "$behind" != 0 ] && arrows+="↓$behind"
        if [ -n "$arrows" ]; then out+=' '; plain+=' '; _prompt_add 36 "$arrows"; fi
        if [ "$stash" != 0 ]; then out+=' '; plain+=' '; _prompt_add 36 "≡$stash"; fi
    fi

    # Right side
    if [ -n "${VIRTUAL_ENV:-}" ]; then
        venv=${VIRTUAL_ENV##*/}
        case $venv in .venv|venv) venv=${VIRTUAL_ENV%/*}; venv=${venv##*/} ;; esac
        safe_venv=$venv
        [ -n "${ZSH_VERSION:-}" ] && safe_venv=${venv//\%/%%}
    fi
    _prompt_node

    status_text=$code
    if [ "$code" -gt 128 ] && [ "$code" -lt 193 ]; then  # killed by a signal: show its name
        status_text=$(kill -l "$(( code - 128 ))" 2>/dev/null) || status_text=$code
        status_text=${status_text#SIG}
    fi

    if [ "$secs" -ge 60 ]; then
        time="$((secs / 60))m$((secs % 60))s"
    elif [ "$secs" -ge 3 ]; then
        time="${secs}s"
    fi
    [ "$code" != 0 ] && arrow=1

    max=$(( ${COLUMNS:-80} - 1 ))   # the last column would wrap in some terminals
    while [ "$level" -ge 0 ]; do
        right=''; rplain=''
        [ "$level" -ge 1 ] && [ "$code" != 0 ] && _prompt_right 31 "✗$status_text"
        [ "$level" -ge 2 ] && [ -n "$time" ] && _prompt_right 33 "$time"
        [ "$level" -ge 3 ] && [ "$jobs" != 0 ] && _prompt_right 36 "⚙$jobs"
        [ "$level" -ge 4 ] && [ -n "${venv:-}" ] && _prompt_right 32 "py:$venv" "py:$safe_venv"
        [ "$level" -ge 5 ] && [ -n "${_PROMPT_NODE:-}" ] && _prompt_right 32 "node $_PROMPT_NODE"
        [ "$level" -ge 6 ] && _prompt_right 2 "$clock"
        pad=$(( max - ${#plain} - ${#rplain} ))
        [ "$pad" -ge 0 ] && break
        level=$(( level - 1 ))
    done
    if [ "$pad" -gt 0 ] && [ -n "$rplain" ]; then
        printf -v spaces '%*s' "$pad" ''
    elif [ "$pad" -lt 0 ]; then
        right=''
    fi

    _PROMPT_LINE="$out$spaces$right"$'\n'"$o${e}3${arrow}m${c}❯$r "
}
