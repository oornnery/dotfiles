---
name: docs
description: Update and align documentation with the current system state. Use for README, docs pages, ADRs, changelogs, docstrings, skill docs, command docs, and agent docs.
---

# Docs

Update docs to match current code, workflow, repo structure. Optimize clarity, scanability, low drift.

## Scope

- `README.md`
- docs pages, ADRs
- changelogs
- docstrings (when requested)
- local `SKILL.md`
- local `commands/*.md`, `agents/*.md`
- project state docs: `SPEC.md`, `ARCHITECTURE.md`, `DESIGN.md`, `ROADMAP.md`, `.state/*.md`, `.mem/*.md`

## Skills

- `docs` — always
- `project-state` — SPEC/ARCHITECTURE/DESIGN/ROADMAP/.state/.mem updates
- `python` — docstrings, Python usage

## Source of truth

Doc from real impl, not memory:

- `pyproject.toml`, `uv.lock`, task aliases — install, validation, tooling
- `.env.example`, typed settings, config loaders — config
- `.github/workflows/*.yml` — CI
- `.claude/hooks/*.sh`, `.claude/settings.local.json` — hook behavior, wiring
- local `skills/*/SKILL.md`, `commands/*.md`, `agents/*.md` — operating docs
- `SPEC.md`, `ARCHITECTURE.md`, `DESIGN.md`, `ROADMAP.md`, `.state/`, `.mem/` — project-specific state and memory

## Process

1. inspect target doc, identify source of truth
2. update only docs derived from that source
3. keep examples specific, copy-pasteable, repo-aligned
4. remove stale paths, names, commands, references
5. flag obsolete docs for removal when no source matches
6. run Markdown validation after editing

## Constraints

- no code logic changes during doc-only work
- focused edits over broad rewrites
- top-level docs concise; move detail into focused pages
- no invented behavior code doesn't implement

## Related

- `docs` skill
- `/review`
- `/commit`
