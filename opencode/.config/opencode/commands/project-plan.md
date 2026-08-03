---
description: Create an implementation plan from a request or brief in the terminal TUI.
agent: planner
---

Plan only; do not implement.

Request or brief: $ARGUMENTS

Inspect project instructions, `.mindmodel/`, current code, tests, and existing
patterns. Resolve obvious technical details from repository evidence. Ask only
for decisions that materially change product behavior, security, or scope.

Produce a dependency-ordered plan with:

- goal and non-goals;
- assumptions and constraints;
- exact files/components affected;
- behavior and data-flow changes;
- security and migration concerns;
- verification and acceptance criteria;
- rollback/recovery notes when risky.

Return the final plan directly in the current TUI conversation. Do not open a
browser or external UI. Stop after the plan; implementation happens separately.
