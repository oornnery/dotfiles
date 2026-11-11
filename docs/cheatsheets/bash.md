# Bash scripts

What the `dots` scripts use, and what a new script needs. Check every script with
`shellcheck script` and `bash -n script`.

## Start

```bash
#!/usr/bin/env bash
# What this does, in one line.
set -euo pipefail    # stop on errors, unset variables, failures in pipes
```

`dots` uses `set -uo pipefail` (no `-e`) and handles each failure itself.

## Variables

| Code | Means |
| ---- | ----- |
| `name=value` | No spaces around `=` |
| `"$name"` | Always quote; `${name}` next to other text |
| `${name:-default}` | Default when unset or empty |
| `${name:?message}` | Stop with the message when unset |
| `${#name}` | Length |
| `${path##*/}` `${path%/*}` | File name, folder |
| `${file%.md}` `${file##*.}` | Without the extension, the extension |
| `${text//old/new}` | Replace all |
| `${text^^}` `${text,,}` | Upper, lower case |
| `$(cmd)` | Output of a command |
| `$(( a + 1 ))` | Arithmetic |

## Arrays

```bash
files=(a.txt "b c.txt")       # list
files+=(d.txt)                # add
for f in "${files[@]}"; do echo "$f"; done
echo "${#files[@]}"           # count
declare -A age=([ana]=31)     # map
echo "${age[ana]}" "${!age[@]}"   # value, keys
mapfile -t lines < file       # lines of a file
```

## Tests and branches

```bash
[[ -f $f ]]  [[ -d $d ]]  [[ -x $f ]]  [[ -n $s ]]  [[ -z $s ]]
[[ $a == "$b" ]]  [[ $s == *.md ]]  [[ $s =~ ^[0-9]+$ ]]
(( n > 3 ))
command -v fzf >/dev/null || echo "no fzf"

case $1 in
    start|run) run ;;
    -h|--help) usage ;;
    *) echo "unknown: $1" >&2; exit 1 ;;
esac
```

## Loops and input

```bash
for i in {1..5}; do ...; done
while IFS= read -r line; do ...; done < file
while IFS= read -r f; do ...; done < <(fd -e md)   # a command, without a subshell
```

## Functions

```bash
greet() {  # greet <name>
    local name=${1:?Usage: greet <name>}
    printf 'hi %s\n' "$name"
}
```

`local` keeps a variable inside; `return 1` is a failure; the output is the result.

## Output and files

| Code | Means |
| ---- | ----- |
| `>&2` | To stderr |
| `> f` `>> f` | Write, append |
| `2>/dev/null` | Hide errors |
| `cmd <<< "$text"` | Text as input |
| `cat <<'EOF' ... EOF` | A block of text, no expansion |
| `tmp=$(mktemp); trap 'rm -f "$tmp"' EXIT` | Temp file, removed at the end |
| `printf '%-10s %s\n' a b` | Formatted, better than echo |

## Arguments

```bash
while (( $# )); do
    case $1 in
        -n) dry=1; shift ;;
        -o) out=${2:?-o needs a file}; shift 2 ;;
        --) shift; break ;;
        *)  args+=("$1"); shift ;;
    esac
done
```
