# API design

- Resource/action naming reflects domain.
- Validate and normalize at boundary.
- Stable error envelope with machine code and human message.
- Pagination/filter/sort semantics explicit.
- Idempotency for retried mutations where needed.
- Authorization and object ownership server-side.
- Version only when compatibility cannot be preserved.
- Document status codes, examples, limits, and failure modes.
