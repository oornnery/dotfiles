---
name: arch
description: Architecture guidance for boundaries, dependency direction, DDD, modular design, patterns, system design documents, and rollout decisions.
---

# Architecture

Choose the smallest lens that resolves real design pressure.

- Boundaries/dependency direction: `references/boundaries.md`
- Recurring implementation shapes: `references/patterns.md`
- System decision and phased rollout: `references/sdd.md`

Shared rules:

- business rules explicit and testable;
- IO/framework/provider details at edges;
- composition before deep inheritance;
- abstraction only when it reduces real coupling or duplication;
- ownership and failure behavior explicit;
- simplest structure that preserves clarity and changeability.
