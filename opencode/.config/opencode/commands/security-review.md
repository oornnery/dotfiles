---
description: Perform an adversarial read-only security review with concrete attack paths and minimal fixes.
agent: reviewer
model: opencode-go/deepseek-v4-pro
subtask: true
---

Security-review scope: $ARGUMENTS

Read-only. Do not edit files, install packages, disclose secret values, or run
destructive commands. When scope is empty, review current diff. Read project
instructions and inspect actual code, configuration, callers, and trust
boundaries. Load `security`; also load `agent-harness` when agents, prompts,
tools, model output, retrieval, or MCP are involved.

Prioritize authentication and authorization bypass, secret exposure, injection,
prompt injection, SSRF, unsafe deserialization, path traversal, PII handling,
cryptography misuse, and exploitable dependency or configuration risk.

Report actionable findings first, ordered by severity. Each finding must include
path:line, attack path, impact, evidence, and smallest fix. Separate confirmed
findings from hypotheses; avoid generic checklist output. If none exist, say so
and list inspected boundaries plus residual risk.
