# Python typing

- Follow configured checker; do not add a second checker during unrelated work.
- Narrow `object`/`unknown` inputs before use. Avoid `Any` at internal boundaries.
- Prefer `Protocol` for consumer-owned interfaces and composition.
- Use type parameters only when multiple concrete types genuinely share behavior.
- Avoid casts/non-null assertions that conceal invalid state.
- Model finite state with enums, literals, or tagged unions.
- Keep overloads small and runtime behavior consistent with signatures.
- Type async iterators, context managers, callbacks, and public exceptions.
