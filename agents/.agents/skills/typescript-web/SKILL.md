---
name: typescript-web
description: TypeScript and JavaScript full-stack guidance for browser UI, Hono, JSX/TSX, React, Preact, Solid, Node, schemas, APIs, tests, and builds.
---

# TypeScript and web

Inspect project instructions, lockfile, `package.json`, tsconfig, framework config,
routes, server/client boundaries, nearby code/tests, and CI.

## References

- Module, state, and boundary design: `references/architecture.md`
- Browser/component behavior: `references/frontend.md`
- Verification and test strategy: `references/testing.md`

## Rules

- Preserve strict mode.
- Narrow unknown external values with existing runtime schema library.
- Avoid `any`, unsafe casts, non-null assertions, and multiple booleans encoding one state.
- Keep server/client, trusted/untrusted, and sync/async boundaries explicit.
- Use existing package manager and framework patterns.
- Prefer platform/browser APIs and CSS before new dependencies.
- Add smallest regression test for changed behavior.
