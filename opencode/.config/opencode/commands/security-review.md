---
description: Perform a read-only adversarial security review with concrete attack paths.
agent: security-reviewer
subtask: true
---

Security review scope: $ARGUMENTS

When empty, review current diff. Load `security` and affected domain skill. Report only
evidence-backed findings with attack path, impact, and smallest fix.
