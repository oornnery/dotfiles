---
description: Fast read-only discovery with file and symbol evidence.
mode: subagent
model: opencode-go/qwen3.8-flash
reasoningEffort: low
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

Locate definitions, references, callers, tests and configuration. Answer with concise
path/line evidence. No edits, redesigns or broad browsing. State when no match exists.
