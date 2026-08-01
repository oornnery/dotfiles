---
name: python
description: Python implementation, debugging, typing, packaging, async, and testing guidance. Use for Python source, pyproject.toml, uv, pytest, Ruff, or type-checking work.
---

# Python engineering

## Discover project contract

Read, in order when present:
1. Project `AGENTS.md` and `.mindmodel/`.
2. `pyproject.toml` and active lockfile.
3. Existing module and nearest tests.
4. CI commands.

Use package manager already selected by lockfile. Do not migrate tooling during
unrelated work.

## Implementation rules

- Prefer stdlib and installed packages.
- Match supported Python version and configured type checker.
- Type public boundaries and non-obvious data structures.
- Use dataclasses, enums, protocols, or typed dicts only when they reduce ambiguity.
- Keep exceptions specific; preserve cause with `raise ... from ...` when translating.
- Validate external data before domain logic.
- Use context managers for files, locks, transactions, and resources.
- Keep async code non-blocking; move unavoidable blocking work off event loop.
- Avoid mutable defaults, import side effects, broad `except Exception`, and hidden globals.

## Verification ladder

Use project commands. Typical order:
1. Focused test: `uv run pytest path::test` or project equivalent.
2. Relevant suite.
3. Ruff/linter.
4. Type checker.
5. Build/package check when packaging changed.

Add one regression test for changed non-trivial behavior. Mock only external
boundaries; prefer real domain objects.
