# Ripgrep (rg) Cheatsheet

Recursive grep on steroids — respects `.gitignore` by default, parallel, fast.

## Basic

| Command             | What it does                              |
| ------------------- | ----------------------------------------- |
| `rg 'pat'`          | Recursive search from `.`                 |
| `rg 'pat' path/`    | Search a specific path                    |
| `rg -i 'pat'`       | Case-insensitive                          |
| `rg -F 'pat'`       | Fixed string (no regex)                   |
| `rg -w 'word'`      | Whole-word match                          |
| `rg -v 'pat'`       | Invert (lines NOT matching)               |
| `rg -c 'pat'`       | Count matches per file                    |
| `rg -l 'pat'`       | List files with matches (no content)      |
| `rg --files`        | List all files rg would search            |
| `rg --files-without-match 'pat'` | List files with NO match     |

## Filters

| Command                  | What it does                                    |
| ------------------------ | ----------------------------------------------- |
| `rg -t py 'pat'`         | Only `.py` files (use `--type-list` to see all) |
| `rg -T py 'pat'`         | All EXCEPT `.py`                                |
| `rg -g '*.tsx' 'pat'`    | Custom glob                                     |
| `rg -g '!node_modules' 'pat'` | Exclude glob                               |
| `rg --hidden 'pat'`      | Include dotfiles                                |
| `rg --no-ignore 'pat'`   | Ignore `.gitignore` (search everything)         |
| `rg -uu 'pat'`           | Same as `--no-ignore --hidden`                  |
| `rg -uuu 'pat'`          | Also search binary files                        |

## Context

| Command           | What it does                                |
| ----------------- | ------------------------------------------- |
| `rg -A 3 'pat'`   | 3 lines AFTER each match                    |
| `rg -B 3 'pat'`   | 3 lines BEFORE                              |
| `rg -C 3 'pat'`   | 3 lines BOTH sides                          |
| `rg --context-separator '---'` | Custom separator              |

## Replace

| Command                       | What it does                       |
| ----------------------------- | ---------------------------------- |
| `rg 'old' --replace 'new'`    | Show what replace would do (dry)   |
| `rg 'old' -r 'new'`           | Short form                         |

> rg does NOT write replacements back. Use `sd` or `sed` for that:
> `rg -l 'old' \| xargs sd 'old' 'new'`

## Regex flavors

| Command                | What it does                                |
| ---------------------- | ------------------------------------------- |
| `rg 'pat'`             | Rust regex engine (default)                 |
| `rg --pcre2 'pat'`     | PCRE2 (lookaround, backrefs)                |
| `rg --engine pcre2 …`  | Same                                        |
| `rg --auto-hybrid-regex …` | Auto-pick engine                        |

## Output format

| Command                       | What it does                       |
| ----------------------------- | ---------------------------------- |
| `rg -n 'pat'`                 | With line numbers (default in TTY) |
| `rg -N 'pat'`                 | Suppress line numbers              |
| `rg --json 'pat'`             | JSON output (per-match)            |
| `rg --color=always 'pat' \| less -R` | Force colors through pager  |
| `rg --hyperlink-format default 'pat'` | Make file:line a terminal link |

## Performance & limits

| Command                         | What it does                       |
| ------------------------------- | ---------------------------------- |
| `rg -j 4 'pat'`                 | Limit to 4 threads                 |
| `rg --max-count 1 'pat'`        | Stop after first match per file    |
| `rg --max-filesize 1M 'pat'`    | Skip files > 1 MB                  |
| `rg --max-depth 2 'pat'`        | Limit recursion depth              |

## Aliases in this repo

| Alias  | Expands to          |
| ------ | ------------------- |
| `grep` | `grep --color=auto` |

> No `rg` alias — name is already short. The user's `.zshrc` keeps `grep` as-is
> so muscle memory across hosts stays intact.

## Common recipes

```bash
# Find TODO comments in TypeScript files only
rg -t ts 'TODO|FIXME'

# List files importing a module
rg -l "from 'lodash'"

# Count log lines per severity
rg -c -P '(?:ERROR|WARN|INFO)' app.log

# Grep but include test files (rg respects .gitignore)
rg -uu 'pat'

# Pipe into fzf for interactive picker
rg --files | fzf

# Replace across all matching files (with sd)
rg -l 'old_name' | xargs sd 'old_name' 'new_name'
```

## Tips

| Tip                                  | Why it helps                            |
| ------------------------------------ | --------------------------------------- |
| Default ignores `.gitignore` files   | No more `node_modules` noise            |
| `-uu` for "search everything"        | When you DO want hidden/ignored content |
| `-t <lang>` is faster than `-g`      | Pre-built type filters skip parsing     |
| `--json` for tooling                 | Stable parseable output                 |
| Combine with `fzf` for interactive   | Best ad-hoc code search                 |
