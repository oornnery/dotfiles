# Git + GitHub CLI Cheatsheet

Daily git workflow + `gh` (GitHub CLI) + `lazygit` TUI (`lg` alias).

## Daily status

| Command                | What it does                              |
| ---------------------- | ----------------------------------------- |
| `git status`           | Working tree state                        |
| `git status -sb`       | Short + branch info                       |
| `git diff`             | Unstaged changes                          |
| `git diff --staged`    | Staged changes (what next commit will be) |
| `git diff HEAD~3 HEAD` | Compare against 3 commits ago             |
| `git diff main...`     | All changes on this branch since main     |
| `git show <ref>`       | Show a commit                             |
| `git blame <file>`     | Line-by-line authorship                   |

## Stage / commit

| Command                          | What it does                       |
| -------------------------------- | ---------------------------------- |
| `git add <file>`                 | Stage file                         |
| `git add -A`                     | Stage all (incl. deletions)        |
| `git add -p`                     | Interactive hunk picker            |
| `git restore --staged <file>`    | Unstage                            |
| `git restore <file>`             | Discard unstaged changes (CAREFUL) |
| `git commit -m "msg"`            | Commit                             |
| `git commit -am "msg"`           | Stage tracked + commit             |
| `git commit --amend`             | Edit last commit                   |
| `git commit --amend --no-edit`   | Add staged to last commit, same msg|
| `git commit --fixup <sha>`       | Fixup commit (autosquash later)    |

## Branches

| Command                       | What it does                          |
| ----------------------------- | ------------------------------------- |
| `git branch`                  | List local branches                   |
| `git branch -a`               | Include remote-tracking               |
| `git switch <branch>`         | Switch (modern, safe)                 |
| `git switch -c <branch>`      | Create + switch                       |
| `git switch -                 ` | Switch to previous branch           |
| `git branch -d <branch>`      | Delete (refuses if unmerged)          |
| `git branch -D <branch>`      | Force delete                          |
| `git branch -m <old> <new>`   | Rename                                |
| `git branch --merged main`    | Branches already merged into main     |

## Remote / sync

| Command                          | What it does                       |
| -------------------------------- | ---------------------------------- |
| `git fetch`                      | Get refs without merging           |
| `git fetch --prune`              | Drop refs deleted upstream         |
| `git pull --rebase`              | Pull + replay local on top         |
| `git pull --rebase --autostash`  | Stash WIP, pull, restore           |
| `git push`                       | Push current branch                |
| `git push -u origin <branch>`    | Push + set upstream                |
| `git push --force-with-lease`    | Safe force (won't clobber others)  |
| `git remote -v`                  | List remotes                       |
| `git remote add <name> <url>`    | Add remote                         |
| `git remote prune origin`        | Drop dead remote refs              |

## Logs / history

| Command                                    | What it does                |
| ------------------------------------------ | --------------------------- |
| `git log --oneline -20`                    | Compact, last 20            |
| `git log --oneline --graph --decorate`     | ASCII graph + branch names  |
| `git log --oneline --graph --all`          | Include all branches        |
| `git log --since '1 week ago'`             | Time filter                 |
| `git log --author 'fabio'`                 | Filter by author            |
| `git log --grep 'fix'`                     | Filter by message           |
| `git log -p <file>`                        | Patch per commit for a file |
| `git log --follow <file>`                  | Follow renames              |
| `git log -S 'string'`                      | Pickaxe — commits adding/removing string |
| `git reflog`                               | Local ref history (lifesaver) |

## Rewriting (use BEFORE pushing)

| Command                          | What it does                              |
| -------------------------------- | ----------------------------------------- |
| `git rebase main`                | Replay current branch on top of main      |
| `git rebase -i HEAD~5`           | Interactive — squash/reorder last 5       |
| `git rebase --autosquash`        | Apply `--fixup` commits automatically     |
| `git rebase --continue`          | After resolving conflict                  |
| `git rebase --abort`             | Bail out, restore pre-rebase state        |
| `git reset --soft HEAD~1`        | Undo last commit, keep changes staged     |
| `git reset --mixed HEAD~1`       | Undo + unstage (default)                  |
| `git reset --hard HEAD~1`        | Undo + DISCARD changes (CAREFUL)          |
| `git cherry-pick <sha>`          | Apply one commit from elsewhere           |
| `git revert <sha>`               | Make a new commit that undoes one         |

## Stash

| Command                          | What it does                              |
| -------------------------------- | ----------------------------------------- |
| `git stash`                      | Save WIP, clean working tree              |
| `git stash -u`                   | Include untracked                         |
| `git stash push -m 'name'`       | Named stash                               |
| `git stash list`                 | List all stashes                          |
| `git stash show -p`              | Diff of latest stash                      |
| `git stash pop`                  | Apply + drop latest                       |
| `git stash apply stash@{1}`      | Apply specific (keep on stack)            |
| `git stash drop`                 | Delete latest                             |

## Worktrees

| Command                                  | What it does                            |
| ---------------------------------------- | --------------------------------------- |
| `git worktree add ../wt-feat feat/X`     | Check out branch in sibling dir         |
| `git worktree list`                      | All worktrees                           |
| `git worktree remove ../wt-feat`         | Remove (cleanup)                        |

## Find what broke (bisect)

```bash
git bisect start
git bisect bad           # current HEAD is broken
git bisect good v1.2.0   # this old tag was good
# git checks out a middle commit — test, then:
git bisect good          # or `bad`
# … repeats until first-bad found
git bisect reset         # back to where you were
```

## GitHub CLI (gh)

| Command                          | What it does                       |
| -------------------------------- | ---------------------------------- |
| `gh auth status`                 | Check auth                         |
| `gh auth login`                  | Login (web or token)               |
| `gh repo view --web`             | Open repo in browser               |
| `gh repo clone <user>/<repo>`    | Clone                              |
| `gh repo fork`                   | Fork current repo                  |
| `gh pr create`                   | Open PR (interactive)              |
| `gh pr create --fill`            | PR with commit msg as title/body   |
| `gh pr list`                     | Open PRs                           |
| `gh pr checkout <n>`             | Check out PR locally               |
| `gh pr view <n>`                 | Inspect PR                         |
| `gh pr view <n> --web`           | Open PR in browser                 |
| `gh pr merge <n>`                | Merge (squash/rebase prompt)       |
| `gh pr review <n> --approve`     | Approve                            |
| `gh pr diff <n>`                 | Show PR diff                       |
| `gh issue list`                  | Open issues                        |
| `gh issue create`                | New issue                          |
| `gh run list`                    | Recent workflow runs               |
| `gh run watch`                   | Watch CI for current branch        |
| `gh release list`                | Releases                           |
| `gh release create v1.0`         | Create release                     |

## Lazygit (`lg` alias)

`lg` opens lazygit — fast TUI. Key panes: Status, Branches, Commits, Stash, Diff.

| Key       | Action                                |
| --------- | ------------------------------------- |
| `?`       | Help (always start here)              |
| `Tab`     | Cycle panels                          |
| `Space`   | Stage / unstage (in Status panel)     |
| `c`       | Commit                                |
| `A`       | Amend last commit                     |
| `P`       | Push                                  |
| `p`       | Pull                                  |
| `s`       | Stash                                 |
| `b`       | Open branch menu                      |
| `Enter`   | Open selected (e.g. inspect commit)   |
| `q`       | Quit                                  |

## Oh-My-Zsh git plugin aliases (common)

| Alias    | Expands to                  |
| -------- | --------------------------- |
| `gst`    | `git status`                |
| `gss`    | `git status -s`             |
| `ga`     | `git add`                   |
| `gaa`    | `git add --all`             |
| `gcmsg`  | `git commit -m`             |
| `gca`    | `git commit -v -a`          |
| `gco`    | `git checkout`              |
| `gcb`    | `git checkout -b`           |
| `gp`     | `git push`                  |
| `gpl`    | `git pull`                  |
| `gd`     | `git diff`                  |
| `glg`    | `git log --stat`            |
| `glol`   | Pretty oneline log w/ graph |
| `grb`    | `git rebase`                |
| `grbi`   | `git rebase -i`             |
| `gsta`   | `git stash`                 |
| `gstp`   | `git stash pop`             |

## Common recipes

```bash
# Safely sync your fork's main with upstream
git fetch upstream
git switch main
git rebase upstream/main
git push

# Squash last 3 commits before push
git rebase -i HEAD~3   # mark commits 2,3 as 'squash' / 'fixup'

# Rename a branch that's already pushed
git branch -m new-name
git push origin -u new-name
git push origin --delete old-name

# Undo a pushed commit (without rewriting history)
git revert <sha>
git push

# Recover a "lost" branch after hard reset
git reflog                    # find the sha
git switch -c recovered <sha>

# Find which commit introduced "TODO foo"
git log -S 'TODO foo' -p
```

## Tips

| Tip                                              | Why it helps                          |
| ------------------------------------------------ | ------------------------------------- |
| Prefer `switch` / `restore` over `checkout`      | One verb, one job (newer, safer)      |
| `--force-with-lease` instead of `--force`        | Refuses to clobber other people's work|
| `--autostash` on `pull --rebase`                 | No "please stash first" loop          |
| `reflog` is the undo log of last resort          | Almost everything is recoverable      |
| Small commits, rebase before pushing             | Easier review + clean history         |
| `lg` for visual ops (stage hunks, amend, etc.)   | Less typing for routine git work      |
| `gh pr create --fill` after a focused commit     | Skips the PR template typing          |
