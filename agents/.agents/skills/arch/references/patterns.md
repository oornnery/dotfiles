# Patterns

Use patterns by demonstrated force:

- Strategy: interchangeable behavior selected by policy.
- Adapter: isolate external interface/vendor.
- Repository: only when persistence boundary benefits domain/testability.
- Unit of Work: coordinated transaction across repositories.
- State machine: finite lifecycle with guarded transitions.
- Command/query split: when mutation/read models have different needs.
- Event: decouple completed fact from downstream reactions.

Do not name a pattern where a function or explicit branch is clearer.
