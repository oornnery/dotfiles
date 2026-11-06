---
name: project-state
description: Record durable project decisions or handoff context when the user needs work to continue across sessions.
---

Use the repository's existing source of truth. Record only changed decisions,
evidence, remaining work and the next useful action. Keep facts separate from
assumptions; link to code and checks instead of copying logs.

Do not require SPEC.md, FORMAT.md, approval gates, commits or a particular folder
layout. Create one short handoff document only when existing docs cannot carry the
needed context. Never duplicate the same state in SPEC/DESIGN/TODO/.spec/.mem.
