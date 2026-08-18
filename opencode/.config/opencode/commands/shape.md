---
description: Turn an idea, context, or file into a clear, implementation-ready project definition.
---

Analyze the idea/context provided, or the file/path pointed to. Turn it into a
clear, implementation-ready project definition.

Idea / context / file / path: $ARGUMENTS

Read everything available first.

Do not invent missing requirements, behavior, constraints, or architecture
decisions. When something important is unclear, conflicting, missing, or has
multiple reasonable solutions, stop and discuss it with the user. Ask only
questions that materially affect the project.

Make assumptions explicit. Never turn an assumption into a requirement without
confirmation.

Challenge unnecessary complexity. Prefer the smallest solution that satisfies
the actual requirements. Do not add abstractions, dependencies, services,
infrastructure, scalability mechanisms, or future-proofing without a concrete
reason.

Reuse existing project structure, conventions, and technology when they
already solve the problem.

Before writing files, briefly tell the user:

- what you understood
- important gaps or conflicts
- decisions still needed
- the simplest direction you recommend

Keep this concise. Once the important decisions are resolved, create or update
the documentation needed to make the project executable by another engineer or
coding agent.

Use only files that provide real value. Examples: `README.md`, `PRD.md`,
`SPEC.md`, `DESIGN.md`, `ARCHITECTURE.md`, `TODO.md`, `ROADMAP.md`,
`AGENTS.md`, `FORMAT.md`, `CONTRIBUTING.md`, `docs/`, ADRs. Do not create
files just because they are listed.

Keep one source of truth for each subject. Avoid duplicated documentation.
Cross-reference instead.

Cover, when relevant:

- `PRD.md`: problem, users, goals, non-goals, scope, requirements, success criteria.
- `SPEC.md`: expected behavior, interfaces, constraints, edge cases, acceptance criteria, testable requirements.
- `DESIGN.md`: implementation approach, components and responsibilities, data/control flow, interfaces, important tradeoffs and rationale.
- `ARCHITECTURE.md`: only when the system is complex enough to need a separate architecture document.
- `TODO.md`: small, atomic, dependency-ordered tasks; each task must have a clear completion condition; expose blockers and unresolved decisions; no vague tasks.
- `AGENTS.md`: rules and constraints for coding agents, project invariants, commands and conventions, source-of-truth documents, things that must not be changed without discussion.
- `FORMAT.md`: only when the project has important formats, schemas, protocols, wire formats, naming rules, or structural conventions worth documenting.
- `README.md`: what the project is, current status, how to run/use it, minimal development entry point, links to deeper documentation.

Use ADRs only for decisions important enough that future contributors need to
understand why they were made.

Unknown things stay unknown. Mark them as open/TBD instead of filling the gap
yourself.

Keep everything short, concrete, and useful. Remove repetition, filler,
obvious explanations, speculative work, and unnecessary ceremony.

Do not implement the project unless explicitly asked.
