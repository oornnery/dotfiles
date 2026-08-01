---
name: verification
description: Evidence-based implementation verification and adversarial acceptance testing. Use when asked to verify, validate, prove, audit completion, or issue PASS/FAIL.
---

# Verification

Verification is independent evidence, not confidence.

## Method

1. Restate testable requirements.
2. Inspect actual diff and affected callers.
3. Map each requirement to code evidence and runnable check.
4. Run focused checks before broad checks.
5. Exercise negative/security paths where relevant.
6. Compare docs/config claims to real behavior.

## Verdicts

- `PASS`: every in-scope requirement has evidence; relevant checks pass.
- `FAIL`: at least one requirement is violated or evidence disproves claim.
- `BLOCKED`: evidence cannot be obtained; state exact missing prerequisite.

Never convert not-run into pass. Never accept a green unrelated test suite as
proof. Report command, exit status, relevant output, and path:line evidence.
