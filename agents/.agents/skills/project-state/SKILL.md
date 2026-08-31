---
name: project-state
description: Maintain durable SPEC, DESIGN, TODO, .spec, and .mem state without storing secrets or noisy transcripts.
---

# Project state

Use for non-trivial work whose decisions, progress, checks, or open loops must survive
sessions.

- `SPEC.md`: objective, scope, requirements, success criteria.
- `DESIGN.md`: architecture, API, UI, data, trade-offs.
- `TODO.md`: current tasks and completion.
- `.spec/state.md`: active milestone and validated state.
- `.spec/handoff.md`: concise continuation context.
- `.mem/decisions.md`: stable decisions and rationale.
- `.mem/open-loops.md`: unresolved but durable questions.

Store validated facts and stable decisions. Do not store secrets, guesses, raw chat,
ephemeral logs, or duplicated documentation. Update only when state materially changes.
