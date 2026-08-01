---
name: agent-harness
description: Agent, LLM, prompt, tool, MCP, evaluation, and human-approval design guidance. Use for AI agents, tool calling, orchestration, prompt injection, or model evaluation work.
---

# Agent harness design

Treat model as untrusted planner, not authority.

## Contracts

- Define each tool with narrow input/output schema, timeout, idempotency, and errors.
- Separate model text from executable commands and trusted system data.
- Validate tool arguments before execution and tool results before reuse.
- Give minimum permissions; scope filesystem, network, credentials, and tenants.
- Require human approval for destructive, financial, external-message, or irreversible actions.
- Keep deterministic logic outside prompts when normal code can enforce it.

## Prompt injection defenses

- Label external content as data, never instructions.
- Never let retrieved text override system policy or tool authorization.
- Sanitize secrets from context, traces, logs, and model-visible errors.
- Prevent data exfiltration through URLs, tool arguments, and generated attachments.

## Reliability and evaluation

- Define observable success criteria before tuning prompts.
- Test tool selection, malformed tool output, retries, timeout, refusal, and low confidence.
- Track unsupported claims, wrong-tool calls, unsafe actions, and human escalations.
- Use deterministic fixtures; record model/provider/version for non-deterministic runs.
- Bound retries and total cost. Fail closed when approval or identity is uncertain.
