---
name: debugging
description: Evidence-driven debugging for reproductions, hypotheses, root cause, regressions, async failures, races, and misleading symptoms.
---

# Debugging

1. Define expected vs observed behavior.
2. Capture smallest reliable reproduction and environment.
3. Trace data/control flow and shared callers.
4. Rank hypotheses by evidence.
5. Run cheapest experiment that distinguishes top hypotheses.
6. Identify root cause before edit.
7. Fix at correct boundary.
8. Add regression check.
9. Rerun reproduction and relevant suite.

Do not fix with arbitrary sleeps, broad retries, swallowed exceptions, cache clears,
test weakening, or unrelated rewrites unless evidence proves those are correct.
