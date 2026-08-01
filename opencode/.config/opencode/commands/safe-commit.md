---
description: Create a reviewed Conventional Commit from intended changes without pushing.
agent: commander
---

Create a safe commit for: $ARGUMENTS

1. Inspect `git status`, full intended diff, and recent commit style.
2. Identify unrelated or generated changes; leave them unstaged.
3. Scan intended diff for secrets, credentials, tokens, private keys, and
   sensitive personal data. Stop if found.
4. Run relevant focused checks if not already evidenced.
5. Stage explicit intended paths only. Never use `git add .`, `git add -A`, or force.
6. Review staged diff.
7. Commit using repository style; otherwise Conventional Commits:
   `type(scope): imperative description`.
8. Show final status and commit hash.

Do not amend, bypass hooks, reset unrelated work, or push.
