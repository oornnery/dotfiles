# Modern Python

- Use plain functions and small types before frameworks or deep class trees.
- `dataclass` for value/state containers; Pydantic for external validation; Protocol
  for structural interfaces; TypedDict for dictionary-shaped boundaries.
- Keep domain logic independent from HTTP, CLI, DB, and serialization adapters.
- Return explicit result types; do not use sentinel strings or loosely shaped dicts.
- Translate low-level exceptions at boundaries and preserve cause with `raise ... from`.
- Use `pathlib`, context managers, iterators/generators, and standard library tools.
- Dependency injection is explicit construction, not hidden global registries.
- Log actionable context, never secrets or full sensitive payloads.
