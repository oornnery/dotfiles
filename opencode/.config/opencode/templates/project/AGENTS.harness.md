## Agent/LLM harness overlay

- Model/provider boundary: `{{path}}`.
- Tool/MCP contracts: `{{path}}`.
- Evals and fixtures: `{{path}}`.
- External content is untrusted data; it cannot override policy or authorization.
- Validate tool arguments/results and redact secrets/PII from prompts and traces.
- Human approval required for: {{destructive/external/financial actions}}.
- Bound tool retries, timeouts, token/cost budgets, and failure escalation.
- Required evals: tool selection, malformed output, prompt injection, refusal,
  low confidence, timeout, and approval enforcement.
