---
description: Fix failing project checks one validation class at a time, preserving strictness.
agent: commander
---

Fix failing checks: $ARGUMENTS

Obtain exact failing command/output. Work one class at a time in this order when
applicable: format, lint, types, unit tests, integration tests, build. For each:
1. Reproduce.
2. Find root cause.
3. Apply smallest correction.
4. Re-run focused check.

After focused fixes, run relevant aggregate gates. Never disable a rule, loosen
types, delete assertions, update snapshots blindly, or skip tests merely to get
