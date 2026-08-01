---
name: docs
description: Code-aligned documentation writing and synchronization. Use for README, architecture, API, operations, troubleshooting, or docs updates derived from code and config.
---

# Documentation

Documentation must describe verified current behavior.

## Workflow

1. Identify audience and task.
2. Read source code, config, commands, tests, and existing docs.
3. Update smallest authoritative document; link instead of duplicating.
4. Run shown commands or label them unverified.
5. Check paths, names, env vars, defaults, and examples against source.

Prefer runnable examples and operational troubleshooting over prose. Never add
secret values, fabricated metrics, future behavior, or architecture unsupported
by code. Documentation-only work must not change business logic.
