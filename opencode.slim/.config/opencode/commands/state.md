---
name: state
description: Update lightweight project state files. Use after planning, implementation, verification, or handoff work that changes SPEC.md, ARCHITECTURE.md, DESIGN.md, ROADMAP.md, .state/, or .mem/.
---

# State

Keep project state current with verified facts and explicit next steps.

## Skills

- `project-state` -- always
- `verification` -- when updating validation status
- `docs` -- when editing top-level docs
- `security` -- when recording trust-boundary or security decisions

## Process

### 1. Read current state

Inspect existing files if present:

```bash
ls SPEC.md ARCHITECTURE.md DESIGN.md ROADMAP.md .state/current.md .state/tasks.md .state/validation.md .state/handoff.md .mem/context.md .mem/decisions.md .mem/pitfalls.md 2>/dev/null
```

### 2. Classify the update

- Scope or requirement changed -> `SPEC.md` and `.state/current.md`
- Architecture, API, UI, or product decision changed -> `ARCHITECTURE.md`/`DESIGN.md` and `.mem/decisions.md`
- Work remains -> `.state/tasks.md`, `.state/handoff.md`
- Validation ran -> `.state/validation.md` and `.state/current.md`
- Stable cross-session fact emerged -> `.mem/context.md`

### 3. Update only what changed

Write concise, dated entries. Use `UNKNOWN` for unresolved facts.

Do not store:

- secrets or credentials
- private data
- raw transcripts
- large command output
- speculative guesses

### 4. Validate docs

Run Markdown validation if configured:

```bash
uv run rumdl check SPEC.md ARCHITECTURE.md DESIGN.md ROADMAP.md .state .mem
```

## Output

Report:

- files updated
- facts or decisions recorded
- next steps now visible
- validation command and result

## Constraints

- no automatic memory writes without inspecting current state
- no duplicate decisions across multiple files
- no changing code during state-only work
