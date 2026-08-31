---
name: building-agents
description: Implement agent applications with tools, structured outputs, state, delegation, memory, safety, observability, and evaluations.
---

# Building agents

Start from task contract and deterministic workflow. Use model only where judgment or
generation is needed. Tools have strict schemas, bounded effects, idempotency, timeout,
and clear errors. Treat tool/model/retrieval output as untrusted. Keep state explicit.
Store durable memory selectively and redact sensitive content. Trace prompts, model,
tools, latency, tokens, and outcomes. Build eval cases from real failures before adding
multi-agent complexity.
