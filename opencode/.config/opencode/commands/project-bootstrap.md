---
description: Apply an approved project-foundation plan without implementing business features.
agent: build
---

Bootstrap project foundation from approved plan or brief: $ARGUMENTS

Require an approved plan or explicit, testable foundation requirements. Create
only agreed structure, configuration, docs, quality gates, and smoke checks.
Do not implement business features, speculative abstractions, deployment, or
credentials.

Workflow:

1. Inspect repository and active instructions.
2. Preserve existing stack and conventions.
3. Apply smallest foundation diff in dependency order.
4. Add or update runnable setup, test, lint, typecheck, and build commands.
5. Verify clean bootstrap path and report evidence.

For agent/LLM systems, load `agent-harness` and `security`. For nontrivial
continuity, load `project-state` and initialize only files actually needed.
