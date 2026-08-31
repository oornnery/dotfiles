---
description: Run a serious read-only code review with GPT-5.6 Sol.
agent: reviewer
subtask: true
---

Review scope: $ARGUMENTS

When empty, review current diff. Inspect callers, tests, configuration, and conventions.
Findings first with severity, `path:line`, impact, evidence, and smallest fix.
