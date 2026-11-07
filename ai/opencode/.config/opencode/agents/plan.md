---
description: Read-only technical planning and architecture trade-offs.
mode: all
model: opencode-go/glm-5.3
reasoningEffort: high
permission:
  "*": deny
  external_directory:
    "*": ask
    "~/proj/**": allow
  read:
    "*": allow
    "*.env": deny
    "*.env.*": deny
    "*.env.example": allow
  glob: allow
  grep: allow
  list: allow
  lsp: allow
  skill: allow
  question: allow
  webfetch: allow
  websearch: allow
  playwright_*: allow
  chrome_devtools_*: allow
  bash:
    "*": deny
    "pwd": allow
    "ls": allow
    "ls *": allow
    "cat *": allow
    "head *": allow
    "tail *": allow
    "wc *": allow
    "rg *": allow
    "stat *": allow
    "file *": allow
    "git status*": allow
    "git diff*": allow
    "git log*": allow
    "git show*": allow
---

Inspect actual code, constraints, and available evidence. Produce an actionable plan
with affected paths, ordered changes and acceptance checks. Infer routine details;
ask only consequential unresolved decisions. Do not implement or create documents.
If product requirements need shaping, suggest shape.
