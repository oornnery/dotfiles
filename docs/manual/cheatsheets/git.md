# Git + GitHub CLI Cheatsheet

## Commands

| Command                                    | What it does                 |
| ------------------------------------------ | ---------------------------- |
| `git status`                               | Shows working tree state     |
| `git add -A && git commit -m "msg"`        | Stage and commit             |
| `git pull --rebase`                        | Update branch with rebase    |
| `gh repo view --web`                       | Open current repo in browser |
| `gh pr create`                             | Create pull request          |
| `git log --oneline --graph --decorate -20` | Compact recent history       |
| `git switch -c <branch>`                   | Create and switch branch     |
| `gh pr list`                               | List open pull requests      |

## Shortcuts

| Shortcut      | Action                            |
| ------------- | --------------------------------- |
| `gst`         | Git status (Oh My Zsh git plugin) |
| `ga`          | Git add                           |
| `gcmsg "msg"` | Commit with message               |
| `gpl`         | Git pull                          |
| `glg`         | Pretty git log (plugin alias)     |

## Examples

```bash
# Safe daily sync
git status
git pull --rebase

# Create feature branch
git switch -c feat/docs-cheatsheets

# Open repo and PR list quickly
gh repo view --web
gh pr list
```

## Tips

| Tip                                 | Why it helps               |
| ----------------------------------- | -------------------------- |
| Use plugin aliases for speed        | Reduces typing overhead    |
| Prefer small commits                | Easier review and rollback |
| Use `gh auth status` when CLI fails | Quick auth diagnostics     |
| Rebase often on active branches     | Fewer merge conflicts      |
