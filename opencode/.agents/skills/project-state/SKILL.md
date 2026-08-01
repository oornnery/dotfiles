---
name: project-state
description: Durable project state, decisions, checks, handoffs, and open-loop guidance. Use for .spec, .mem, project handoffs, long-running milestones, or cross-session continuity.
---

# Project state

Store only facts future work must recover.

## Ownership

- Cavemem: session observations and cross-agent recall.
- Project docs: accepted product, architecture, security, and operating decisions.
- `.spec/`: current milestone state, acceptance checks, and handoff.
- `.mem/`: optional hot facts, durable decisions, and open loops for complex projects.

Do not mirror whole conversations or duplicate Cavemem. Keep files small and
update existing entries instead of appending stale narratives.

## State entry

Record: date, status, evidence, next action, owner only when relevant, and links

Remove resolved hot state; preserve durable decisions and historical handoffs.
