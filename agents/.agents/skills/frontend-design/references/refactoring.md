# Frontend refactoring

1. Inventory routes, components, styles, state, data fetching, and duplicated patterns.
2. Record behavior that must not change.
3. Identify one seam: tokens, primitive, feature, route, or state boundary.
4. Add/confirm regression coverage.
5. Refactor incrementally with working build after each slice.
6. Remove duplication only after new path is proven.
7. Inspect representative pages, breakpoints, and states.

Do not combine framework migration, redesign, data-layer rewrite, and behavior changes in
one uncontrolled diff.
