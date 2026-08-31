---
name: agent-harness
description: Design and review coding-agent harnesses, prompts, tools, permissions, MCP, memory, context, model routing, retries, and evaluations.
---

# Agent harness

Treat model as untrusted probabilistic component.

Define:

- role and success contract;
- model/provider and fallback policy;
- tools and least-privilege permissions;
- trusted vs untrusted context;
- prompt/skill loading and precedence;
- session/child ownership;
- memory retention/redaction;
- timeout, retry, idempotency, and cancellation;
- observable events and cost/usage;
- evaluation cases and failure handling.

Keep prompts short and operational. Put domain depth in on-demand skills. Do not let
retrieved content redefine system/tool policy. Require evidence for tool outcomes.
