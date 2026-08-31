---
name: python
description: Modern Python implementation, debugging, typing, packaging, asyncio, testing, and uv guidance. Use for Python source, pyproject.toml, pytest, Ruff, ty, libraries, CLIs, or services.
---

# Python engineering

Read project contract, `pyproject.toml`, active lockfile, Python version, nearest code
and tests, then CI. Existing project decisions override these defaults.

## Reference map

- Core implementation and data modeling: `references/modern.md`
- Type design and type-checking: `references/typing.md`
- Async/concurrency/cancellation: `references/asyncio.md`
- pytest and regression strategy: `references/testing.md`
- Packaging, uv, scripts, and releases: `references/packaging.md`

## Rules

- Prefer stdlib and installed packages.
- Type public boundaries and non-obvious structures.
- Validate external data before domain logic.
- Keep exceptions specific and preserve cause when translating.
- Use context managers for files, locks, transactions, clients, and resources.
- Keep async code non-blocking and cancellation-safe.
- Avoid mutable defaults, import side effects, hidden globals, broad exception
  swallowing, and speculative abstractions.
- Match configured formatter, linter, type checker, tests, and supported Python.
- New non-trivial behavior gets a focused regression test.

## Verification

Use project commands. Typical ladder:

1. focused test;
2. relevant suite;
3. Ruff/linter;
4. ty/mypy/pyright;
5. package/build check when affected.
