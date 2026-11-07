---
description: Create a reviewed Conventional Commit from the intended changes, without pushing.
argument-hint: [what the commit covers]
disable-model-invocation: true
allowed-tools: Bash(git status:*), Bash(git diff:*), Bash(git log:*), Bash(git add:*), Bash(git commit:*), Read, Grep, Glob
---

Create a safe commit for: $ARGUMENTS

1. Inspect `git status`, the full intended diff, and the recent commit style.
2. Identify unrelated or generated changes; leave them unstaged.
3. Scan the intended diff for secrets, credentials, tokens, private keys and sensitive
   personal data. Stop if you find any.
4. Run the relevant focused checks if the diff has no evidence they passed.
5. Stage explicit intended paths only. Never `git add .`, `git add -A`, or force.
6. Review the staged diff.
7. Commit in the repository's style; otherwise Conventional Commits:
   `type(scope): imperative description`.
8. Show the final status and the commit hash.

Never amend, bypass hooks, reset unrelated work, or push.
