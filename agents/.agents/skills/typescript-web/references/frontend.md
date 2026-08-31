# Browser and component behavior

- Semantic HTML first.
- Labels, keyboard access, visible focus, reduced motion, contrast, and live-region
  behavior where needed.
- Handle loading, empty, error, success, stale, disabled, and optimistic states.
- Derive state instead of synchronizing duplicates.
- Keep effects for external synchronization, not ordinary derivation.
- Avoid prop drilling with global stores as first response; colocate state by ownership.
- Measure before memoizing.
- Preserve URL/history semantics for navigation and filters.
