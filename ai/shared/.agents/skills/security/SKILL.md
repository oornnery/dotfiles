---
name: security
description: Threat modeling and secure implementation for auth, authorization, secrets, injection, SSRF, files, subprocesses, PII, cryptography, dependencies, prompts, tools, and MCP.
---

# Security

Map assets, attacker-controlled inputs, entry points, trust boundaries, privileged
operations, sensitive sinks, and failure impact.

Rules:

- authenticate identity and authorize every protected object/action server-side;
- deny by default and minimize privilege;
- validate/canonicalize at boundary, encode at sink;
- parameterize queries and structured commands;
- restrict outbound network and filesystem scope;
- never expose secrets/PII in logs, errors, prompts, fixtures, or telemetry;
- use maintained cryptographic primitives and secure randomness;
- protect agent tools from prompt injection and untrusted retrieved instructions;
- verify negative paths and abuse cases;
- prioritize concrete attack paths over generic hardening.
