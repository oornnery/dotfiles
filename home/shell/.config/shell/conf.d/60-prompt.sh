# shellcheck shell=bash disable=SC2016,SC2034,SC2154,SC2296
# The prompt, the same in zsh and bash: everything about it is in this file.
# Terminal colors only, so it follows `dots theme`; icons from a Nerd Font.
#
#   [box] user  ~/dotfiles  main +1 *2 ?3 ↑1 ↓2 ≡1    ✗INT 3  12s  ⚙2  app  py 3.14  14:32  Alt / ? u
#   ❯
#
# Left, who and where: container, user (@host on SSH), folder, git.
# Git: staged, changed, untracked, conflicts, ahead, behind, stashes, each with its count.
# Right, what happened and with what: error, what dots status left pending, time from
# 3s, background jobs, Python venv, the languages of this project, clock, and outside
# Zellij (its bar has them) three keys: Alt / search, Alt ? help, Alt u TUIs;
# DOTS_PROMPT_KEYS=0 hides them. When the line does not fit, they leave from the
# right; the error goes last. The pending count is read from the cache of dots
# status, which a new shell refreshes in the background (30-dots.sh).

_PI_BOX=$'' _PI_SSH=$'' _PI_USER=$'' _PI_HOME=$'' _PI_DIR=$''
_PI_BRANCH=$'' _PI_STAGED=$'' _PI_CHANGED=$'' _PI_UNTRACKED=$''
_PI_CONFLICT=$'' _PI_AHEAD=$'' _PI_BEHIND=$'' _PI_STASH=$''
_PI_ERROR=$'' _PI_TIME=$'' _PI_JOBS=$'' _PI_VENV=$'' _PI_CLOCK=$''
_PI_PENDING=$'\uf0ae' _PI_KEYS=$'\uf11c'

_prompt_add() {  # _prompt_add <color> <text> [text for the prompt, if it differs]
    out+="$o${e}${1}m$c${3:-$2}$r"
    plain+=$2
}

_prompt_right() {  # same as _prompt_add, for the right side
    right+="  $o${e}${1}m$c${3:-$2}$r"
    rplain+="  $2"
}

_prompt_git() {  # _prompt_git <color> <icon> <count>: only when there are any
    [ "$3" = 0 ] && return
    out+=' '; plain+=' '
    _prompt_add "$1" "$2$3"
}

_prompt_lang() {  # _prompt_lang <icon> <version command> <files...>: if one of them is at the root
    local icon=$1 command=$2 file version
    shift 2
    for file in "$@"; do
        [ -e "$root/$file" ] || continue
        # The first number.number of what the command prints; some languages have none.
        version=$(cd "$root" && eval "$command" 2>/dev/null | sed -nE 's/[^0-9]*([0-9]+\.[0-9]+).*/\1/p' | head -n 1)
        _PROMPT_LANGS+="${_PROMPT_LANGS:+  }$icon${version:+ $version}"
        return
    done
}

_prompt_langs() {  # the languages of this project; looks once per folder and venv
    local root=$PWD
    [ "${_PROMPT_LANGS_KEY:-}" = "$PWD:${VIRTUAL_ENV:-}" ] && return
    _PROMPT_LANGS_KEY="$PWD:${VIRTUAL_ENV:-}"
    _PROMPT_LANGS=''
    # From a subfolder, look at the root of the repository.
    while [ "$root" != / ] && [ "$root" != "$HOME" ] && [ ! -e "$root/.git" ]; do
        root=${root%/*}
        root=${root:-/}
    done
    [ -e "$root/.git" ] || root=$PWD
    _prompt_lang $'' 'if [ -z "${VIRTUAL_ENV:-}" ] && [ -r .python-version ]; then cat .python-version; else python3 --version; fi' \
        pyproject.toml requirements.txt setup.py .python-version
    _prompt_lang $'' 'node --version' package.json
    _prompt_lang $'' 'rustc --version' Cargo.toml
    _prompt_lang $'' 'go version' go.mod
    _prompt_lang $'' 'lua -v' .luarc.json init.lua
    _prompt_lang $'' 'java --version' pom.xml build.gradle build.gradle.kts
    _prompt_lang $'' 'php --version' composer.json
    _prompt_lang $'' 'ruby --version' Gemfile
    _prompt_lang $'' 'zig version' build.zig
    _prompt_lang $'' 'cc --version' CMakeLists.txt
    _prompt_lang $'' ':' Dockerfile compose.yaml compose.yml docker-compose.yml
}

_prompt_build() {  # _prompt_build <exit code> <seconds> <jobs> <clock> <open> <close>
    local code=$1 secs=$2 jobs=$3 clock=$4 o=$5 c=$6 e=$'\033[' r
    local dir safe_dir branch='' safe_branch oid='' ahead=0 behind=0 line ab xy venv arrow=2 icon
    local staged=0 changed=0 untracked=0 conflict=0 out='' plain=''
    local time='' level=8 right pending='' keys='' rplain pad=0 spaces='' max stash=0 status_text='' safe_venv=''
    r="$o${e}0m$c"

    icon=$_PI_DIR
    case $PWD in
        "$HOME")   dir='~'; icon=$_PI_HOME ;;
        "$HOME"/*) dir="~${PWD#"$HOME"}"; icon=$_PI_HOME ;;
        *)         dir=$PWD ;;
    esac

    while IFS= read -r line; do
        case $line in
            '# branch.oid '*)  oid=${line#\# branch.oid } ;;
            '# branch.head '*) branch=${line#\# branch.head } ;;
            '# branch.ab '*)   ab=${line#\# branch.ab +}; ahead=${ab%% *}; behind=${ab##*-} ;;
            '# stash '*)       stash=${line#\# stash } ;;
            '? '*) untracked=$(( untracked + 1 )) ;;
            'u '*) conflict=$(( conflict + 1 )) ;;
            '1 '*|'2 '*)
                xy=${line#? }; xy=${xy%% *}
                [ "${xy%?}" = . ] || staged=$(( staged + 1 ))
                [ "${xy#?}" = . ] || changed=$(( changed + 1 )) ;;
        esac
    done < <(command git --no-optional-locks status --porcelain=v2 --branch --show-stash 2>/dev/null)
    [ "$branch" = '(detached)' ] && branch=${oid%"${oid#???????}"}

    safe_dir=$dir; safe_branch=$branch
    if [ -n "${ZSH_VERSION:-}" ]; then  # % is special in zsh prompts
        safe_dir=${dir//\%/%%}; safe_branch=${branch//\%/%%}
    fi

    # Left side
    if [ -n "${CONTAINER_ID:-}" ]; then _prompt_add 33 "$_PI_BOX $CONTAINER_ID"; out+=' '; plain+=' '; fi
    if [ -n "${SSH_CONNECTION:-}" ]; then
        _prompt_add 32 "$_PI_SSH ${USER:-}@${HOSTNAME:-${HOST:-}}"
    else
        _prompt_add 32 "$_PI_USER ${USER:-}"
    fi
    out+=' '; plain+=' '
    _prompt_add 36 "$icon $dir" "$icon $safe_dir"

    if [ -n "$branch" ]; then
        out+=' '; plain+=' '
        _prompt_add 35 "$_PI_BRANCH $branch" "$_PI_BRANCH $safe_branch"
        _prompt_git 32 "$_PI_STAGED" "$staged"
        _prompt_git 33 "$_PI_CHANGED" "$changed"
        _prompt_git 34 "$_PI_UNTRACKED" "$untracked"
        _prompt_git 31 "$_PI_CONFLICT" "$conflict"
        _prompt_git 36 "$_PI_AHEAD" "$ahead"
        _prompt_git 36 "$_PI_BEHIND" "$behind"
        _prompt_git 36 "$_PI_STASH" "$stash"
    fi

    # Right side
    if [ -n "${VIRTUAL_ENV:-}" ]; then
        venv=${VIRTUAL_ENV##*/}
        case $venv in .venv|venv) venv=${VIRTUAL_ENV%/*}; venv=${venv##*/} ;; esac
        safe_venv=$venv
        [ -n "${ZSH_VERSION:-}" ] && safe_venv=${venv//\%/%%}
    fi
    _prompt_langs

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

    # What dots status left pending, from its cache: a read, no command.
    [ -r "${XDG_CACHE_HOME:-$HOME/.cache}/dots/pending" ] && read -r pending < "${XDG_CACHE_HOME:-$HOME/.cache}/dots/pending"
    [ "${pending:-0}" = 0 ] && pending=''
    [ -z "${ZELLIJ:-}" ] && [ "${DOTS_PROMPT_KEYS:-1}" != 0 ] && keys="$_PI_KEYS Alt / search • ? help • u tui"

    max=$(( ${COLUMNS:-80} - 1 ))   # the last column would wrap in some terminals
    while [ "$level" -ge 0 ]; do
        right=''; rplain=''
        [ "$level" -ge 1 ] && [ "$code" != 0 ] && _prompt_right 31 "$_PI_ERROR $status_text"
        [ "$level" -ge 2 ] && [ -n "$pending" ] && _prompt_right 35 "$_PI_PENDING $pending"
        [ "$level" -ge 3 ] && [ -n "$time" ] && _prompt_right 33 "$_PI_TIME $time"
        [ "$level" -ge 4 ] && [ "$jobs" != 0 ] && _prompt_right 36 "$_PI_JOBS $jobs"
        [ "$level" -ge 5 ] && [ -n "${venv:-}" ] && _prompt_right 32 "$_PI_VENV $venv" "$_PI_VENV $safe_venv"
        [ "$level" -ge 6 ] && [ -n "${_PROMPT_LANGS:-}" ] && _prompt_right 33 "$_PROMPT_LANGS"
        [ "$level" -ge 7 ] && _prompt_right 2 "$_PI_CLOCK $clock"
        [ "$level" -ge 8 ] && [ -n "$keys" ] && _prompt_right 2 "$keys"
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

# Each shell asks for the prompt in its own way, and passes its own codes to mark what
# takes no room on the line.
if [ -n "${ZSH_VERSION:-}" ]; then
    _prompt_preexec() { _prompt_start=$SECONDS; }

    _prompt_precmd() {
        local code=$? secs=0 format='%D{%H:%M}'
        [[ -n ${_prompt_start:-} ]] && secs=$(( SECONDS - _prompt_start ))
        unset _prompt_start
        _prompt_build "$code" "$secs" "${#jobstates}" "${(%)format}" '%{' '%}'
    }

    autoload -Uz add-zsh-hook
    add-zsh-hook preexec _prompt_preexec
    precmd_functions=(_prompt_precmd "${precmd_functions[@]}")   # first: it must read $?
    setopt PROMPT_SUBST
    PROMPT='${_PROMPT_LINE}'
else
    # Saves the start time and prints nothing. Reads PS1 because bash skips the
    # arithmetic when the variable it expands is unset.
    PS0='${PS1:$((_prompt_start=SECONDS,0)):0}'

    _prompt_bash() {
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
        PROMPT_COMMAND=(_prompt_bash "${PROMPT_COMMAND[@]}")
    else
        # shellcheck disable=SC2178,SC2128  # a plain string on this branch
        PROMPT_COMMAND="_prompt_bash${PROMPT_COMMAND:+; $PROMPT_COMMAND}"
    fi
    PS1='${_PROMPT_LINE}'
fi
