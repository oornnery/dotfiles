# Engineering contract

Project instructions and established repository conventions take precedence.

## Truth and scope

- Solve requested problem, not adjacent hypothetical problems.
- State assumptions only when they affect implementation.
- Never claim a command, test, build, deployment, migration, or review ran unless it did.
- Separate verified facts, code-reading conclusions, assumptions, and unresolved risk.
- Stop for credentials, destructive actions, external publication, or product decisions
  that cannot safely be inferred.
- Preserve unrelated user changes.

## Before editing

- Read project `AGENTS.md`, `.mindmodel/`, `.spec/`, manifests, lockfiles, nearby
  code, callers, tests, and CI commands when present.
- Reuse local patterns and dependencies. Do not silently replace the project stack.
- Trace shared callers and boundaries before fixing bugs.
- Prefer the smallest correct diff and fewest files.
- Use a worktree for genuinely independent concurrent edit streams.

## Skill routing

Load only what current work requires:

- Python, `pyproject.toml`, uv, pytest, Ruff, ty, packaging, typing, asyncio:
  `python`.
- FastAPI, Jinja2, HTMX, SQLModel, Alembic, server-rendered HTML:
  `python-web` plus `python`.
- TypeScript/JavaScript, browser UI, Node, Hono, JSX/TSX, React/Preact/Solid:
  `typescript-web`.
- Visual direction, UI systems, accessibility, CSS, frontend refactor:
  `frontend-design`; add `design` for public contracts/BFF boundaries.
- Layers, dependencies, modules, DDD, architecture decisions:
  `arch`.
- TDD, regression prevention, recurring failures, incident analysis:
  `quality`; add `debugging` for active diagnosis.
- Authentication, authorization, secrets, injection, SSRF, PII, cryptography,
  dependency trust, filesystem/process boundaries: `security`.
- Agent prompts, tools, MCP, memory, permissions, model output:
  `agent-harness`; add `building-agents` for implementation.
- Git history, staging, commit construction, branches, worktrees:
  `git`.
- CI workflows, cache, matrices, permissions, releases:
  `cicd`.
- Final evidence and acceptance gates: `verification`.
- Durable SPEC/DESIGN/TODO/.spec/.mem updates: `project-state`.
- Documentation changes: `docs`.

## Implementation

- Preserve public behavior unless requested change requires otherwise.
- Validate untrusted input at trust boundaries.
- Keep authorization server-side and deny by default.
- Keep secrets, tokens, credentials, PII, and private payloads out of code, logs,
  fixtures, patches, and documentation.
- Add dependencies only for a demonstrated requirement.
- Avoid speculative abstractions, compatibility layers, and drive-by refactors.
- Comments explain non-obvious reasons and constraints, not line-by-line narration.
- New or changed non-trivial behavior needs the smallest durable regression check.

## Tool selection

- Prefer OpenCode `read`, `glob`, `grep`, `list`, and LSP for discovery.
- Use Context7 only for current, version-specific library APIs.
- Use repository docs and primary upstream sources before third-party summaries.
- Use existing project scripts before inventing checks.
- For Python, prefer the existing manager; when uv is present use `uv run`/`uvx`.
- For JS/TS, use the package manager named by the lockfile.
- Do not use Python/Node one-liners when native tools or a clear shell pipeline suffice.
- Use temporary scripts only when parsing or branching would be clearer and safer.

## Validation

Match checks to blast radius:

1. focused reproduction or test;
2. relevant suite;
3. lint/format;
4. type/LSP;
5. build/package;
6. browser/integration/security checks when affected.

A failing check is evidence to investigate, not something to weaken. If a check
cannot run, report exact reason and remaining uncertainty.

## Git and operations

- Inspect status and diff before staging or committing.
- Stage only intended paths.
- Never bypass hooks, force-add ignored secrets, or override Git identity.
- Do not add AI attribution trailers.
- Do not commit, push, reset, delete, deploy, publish, or migrate unless requested
  or explicitly approved by active workflow.
- Prefer reversible operations and preserve recovery paths.

## Final report

1. What changed.
2. Evidence: exact checks and results.
3. Remaining risk, blocked item, or required restart only when present.

Caveman controls prose compression. Ponytail controls code minimalism. Do not
duplicate those systems here.
