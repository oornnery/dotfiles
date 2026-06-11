# fd Cheatsheet

Modern `find` — sane defaults, respects `.gitignore`, parallel, no `-type f` boilerplate.

## Basic

| Command             | What it does                              |
| ------------------- | ----------------------------------------- |
| `fd`                | List everything (recursive from `.`)      |
| `fd 'pat'`          | Find files/dirs matching regex `pat`      |
| `fd 'pat' path/`    | Search a specific path                    |
| `fd -e md`          | All `.md` files                           |
| `fd -e ts -e tsx`   | Multiple extensions                       |
| `fd -t f`           | Only files                                |
| `fd -t d`           | Only directories                          |
| `fd -t l`           | Only symlinks                             |
| `fd -t e`           | Only executable files                     |

## Filters

| Command                     | What it does                              |
| --------------------------- | ----------------------------------------- |
| `fd -H 'pat'`               | Include hidden (dotfiles)                 |
| `fd -I 'pat'`               | Ignore `.gitignore` (search everything)   |
| `fd -HI 'pat'`              | Hidden + no-ignore                        |
| `fd -E node_modules 'pat'`  | Exclude glob                              |
| `fd --max-depth 2 'pat'`    | Limit recursion                           |
| `fd --max-results 10 'pat'` | Cap output                                |
| `fd -s 'PAT'`               | Case-sensitive (default is smart-case)    |
| `fd -i 'pat'`               | Force case-insensitive                    |
| `fd -p '.*/sub/.*'`         | Match full path (not just filename)       |
| `fd --changed-within 1d`    | Modified in last day                      |
| `fd --size +10M`            | Larger than 10 MB                         |

## Execute on matches

```bash
# Execute per match (placeholders: {} = path, {/} = basename, {.} = no ext)
fd -e md -x rumdl fmt {}
fd -e py -x ruff format {}

# Aggregate (--exec-batch, like xargs)
fd -e log -X rm
```

## Common recipes

```bash
# Find all TS files, send to fzf
fd -e ts | fzf

# Delete all .pyc files
fd -e pyc -X rm

# Count source files by extension
fd -t f -e py | wc -l
fd -t f -e ts | wc -l

# Find files modified today
fd --changed-within 24h

# Find big files
fd --size +50M

# Open .md picker in editor
fd -e md docs | fzf | xargs -r nvim
```

## fd vs find

| Task                 | find                                    | fd                  |
| -------------------- | --------------------------------------- | ------------------- |
| All `.md` files      | `find . -name '*.md' -type f`           | `fd -e md`          |
| Skip `node_modules`  | `find . -path './node_modules' -prune` | (automatic)         |
| Find + delete        | `find . -name '*.log' -delete`          | `fd -e log -X rm`   |
| Recurse one level    | `find . -maxdepth 2 -name '…'`          | `fd --max-depth 2`  |
| Case-insensitive     | `find . -iname '*.MD'`                  | `fd 'md'` (smart)   |

## Tips

| Tip                                 | Why it helps                          |
| ----------------------------------- | ------------------------------------- |
| Default ignores `.gitignore`        | Same as `rg` — consistent UX          |
| Smart-case search                   | Lowercase = case-insensitive          |
| `-x` runs per-match in parallel     | Faster than `xargs -n 1`              |
| Use `-e` (not regex) for extensions | Faster + clearer                      |
| Pipe to fzf for interactive picker  | `fd … \| fzf` is half the bin/ helpers|
