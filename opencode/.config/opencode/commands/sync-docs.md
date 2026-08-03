---
description: Synchronize documentation with verified code, config, and commands without changing application logic.
agent: build
---

Synchronize docs: $ARGUMENTS

Load `docs` skill. Read source code, configuration, scripts, tests, and current
documentation. Update only authoritative docs affected by real behavior.

Verify commands, paths, environment variable names, defaults, and examples.
Link to existing source instead of duplicating large explanations. Do not change
application logic, invent future behavior, include secret values, or claim
unrun commands succeeded.

Report docs changed and verification performed.
