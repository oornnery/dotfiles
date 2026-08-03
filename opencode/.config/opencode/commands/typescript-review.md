---
description: Review TypeScript and JavaScript changes for correctness, type safety, boundaries, accessibility, and test gaps without editing files.
agent: reviewer
model: opencode-go/kimi-k2.7-code
subtask: true
---

Review TypeScript/JavaScript scope: $ARGUMENTS

Read-only. Do not edit files, install packages, or run auto-fix commands. When
scope is empty, review current diff. Read project instructions, `package.json`,
lockfile, TypeScript config, affected callers, and nearby tests. Query
`.mindmodel/` when present and load `typescript-web`.

Check correctness, strict typing, runtime validation, server/client and async
boundaries, framework conventions, accessibility, dependency use, and
regression coverage. Identify relevant checks for the caller to run when
evidence is incomplete.

Report actionable findings first, ordered by severity. Each finding must include
path:line, impact, evidence, and smallest fix. Separate confirmed defects from
questions. If none exist, say so and list inspected evidence plus residual risk.
