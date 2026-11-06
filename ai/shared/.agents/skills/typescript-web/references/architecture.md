# TypeScript architecture

- Keep domain/feature modules independent from framework adapters where practical.
- Put validation at network, storage, env, URL, form, and message boundaries.
- Share schemas/contracts only when runtime and ownership semantics match.
- Separate server-only code from browser bundles.
- Keep effects at edges and state transitions explicit.
- Avoid universal utility folders that erase feature ownership.
- For Hono/BFF, keep transport parsing, service orchestration, and persistence separate.
