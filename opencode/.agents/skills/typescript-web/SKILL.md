---
name: typescript-web
description: TypeScript, JavaScript, web UI, API, Node.js, and browser implementation guidance. Use for package.json, tsconfig, frontend, backend, or full-stack TypeScript work.
---

# TypeScript and web engineering

## Discover project contract

Read project instructions, `.mindmodel/`, `package.json`, active lockfile,
tsconfig, framework config, nearby code/tests, and CI scripts. Use existing
package manager and component/data patterns.

## Types and boundaries

- Keep strict mode and narrow unknown values before use.
- Avoid `any`, non-null assertions, and casts that suppress real uncertainty.
- Reuse runtime schemas for external data when project has a schema library.
- Represent finite states explicitly; avoid several booleans encoding one state.
- Preserve server/client, trusted/untrusted, and sync/async boundaries.

## Web behavior

- Use semantic HTML, keyboard access, labels, and visible focus.
- Prefer native browser APIs and CSS before JavaScript or dependencies.
- Handle loading, empty, error, and success states when user-visible.
- Do not put secrets or privileged authorization decisions in client code.
- Encode and validate URL, form, storage, network, and environment values.

## Verification ladder

Use repository scripts, typically:
1. Focused unit/component test.
2. Typecheck.
3. Lint/format check.
4. Relevant integration or browser test.
5. Production build when routing, bundling, or server/client boundaries changed.

Add smallest regression test that would fail before fix.
