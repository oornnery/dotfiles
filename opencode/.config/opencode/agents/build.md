---
description: Daily implementation, using existing project conventions.
mode: primary
model: openai/gpt-5.6-terra
reasoningEffort: medium
permission:
  task:
    "*": deny
    explore: allow
    fast: allow
    plan: allow
    reviewer: allow
    security-reviewer: allow
    verifier: allow
---

Complete the requested repository change. Inspect relevant code and use the stack
skill when it adds project-specific guidance. Plan only as much as the task needs.
Verify changed behavior with sufficient focused checks. No automatic commits.
