---
name: security
description: Application security review and implementation guidance. Use for authentication, authorization, secrets, injection, SSRF, PII, cryptography, dependency risk, or trust-boundary changes.
---

# Security engineering

## Threat model first

Identify assets, actors, trust boundaries, entry points, and worst plausible
impact. Review actual data flow; checklist-only findings are noise.

## Required controls

- Authenticate identity before authorization; authorize each protected object/action.
- Deny by default; do not trust client-provided roles, tenant IDs, prices, or ownership.
- Validate shape, size, encoding, and destination of untrusted input.
- Parameterize queries and commands; constrain paths, redirects, and outbound URLs.
- Store secrets outside repository; redact logs/errors; rotate after exposure.
- Minimize PII collection, retention, context propagation, and observability payloads.
- Use platform cryptography; never invent primitives or compare secrets unsafely.
- Set timeouts, size limits, and bounded retries on network/resource boundaries.

## Review output

For each actionable issue: severity, CWE/class when useful, path:line, attacker
precondition, exploit path, impact, and minimal fix. Separate confirmed issue
from hypothesis. Ignore theoretical risks without a reachable path.
