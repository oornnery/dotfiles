---
description: Reproduce, isolate, fix, and verify a bug using evidence rather than guesswork.
agent: commander
---

Debug: $ARGUMENTS

1. Capture expected behavior, observed behavior, and smallest reproduction.
2. Inspect relevant flow and every caller of shared code.
3. Form hypotheses ranked by evidence; test cheapest discriminating hypothesis.
4. Identify root cause before editing.
5. Apply smallest shared fix that preserves unrelated behavior.
6. Add smallest regression check that fails before fix.
7. Run focused then relevant broader checks.

When failure reveals a durable invariant missing from project spec, load and
apply `backprop`. Do not paper over symptoms, weaken tests, or add retries
without proving transient failure.

Report root cause, fix, reproduction/regression evidence, and remaining risk.
