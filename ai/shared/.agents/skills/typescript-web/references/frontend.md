# Browser and component behavior

- Semantic HTML first.
- Labels, keyboard access, visible focus, reduced motion, contrast, and live-region
  behavior where needed.
- Handle the states the component can reach: loading, empty, error, success, and
  disabled, plus stale or optimistic when data is cached or mutated.
- Derive state instead of synchronizing duplicates.
- Keep effects for external synchronization, not ordinary derivation.
- Avoid prop drilling with global stores as first response; colocate state by ownership.
- Measure before memoizing.
- Preserve URL/history semantics for navigation and filters.
