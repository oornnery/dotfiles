# Engineering contract

Apply these rules to engineering work. Project instructions and established
repository conventions take precedence when more specific.

## Scope and truth

- Solve requested problem, not adjacent hypothetical problems.
- State assumptions only when they affect implementation.
- Never claim a command, test, build, deployment, or review ran unless it did.
- Distinguish verified facts, code-reading conclusions, and unresolved risks.
- Stop and report when credentials, user decisions, or destructive action are required.

## Before editing

- Read project instructions, manifests, lockfiles, and relevant code paths.
- Query `.mindmodel/` when present; follow its constraints and examples.
- Trace callers and boundaries before fixing bugs; repair root cause at shared point.
- Reuse local patterns and dependencies. Do not silently replace project stack.
- Keep unrelated user changes intact.

## Implementation

- Prefer smallest correct diff and fewest files.
- Preserve public behavior unless change explicitly requires otherwise.
- Validate untrusted input at trust boundary.
- Keep secrets, credentials, tokens, and personal data out of code, logs, fixtures,
  patches, and documentation.
- Make authorization server-side and deny by default.
- Use comments for non-obvious reasons, constraints, and tradeoffs; not narration.
- Do not add speculative abstractions, compatibility layers, or dependencies.

## Validation

- Match checks to blast radius: focused test first, then relevant typecheck/lint/build.
- New or changed non-trivial behavior needs smallest durable regression check.
- Test failure means investigate cause; never weaken checks to obtain green output.
- Security-sensitive changes require explicit negative-path checks.
- If a check cannot run, report exact reason and remaining uncertainty.

## Git and operations

- Inspect status and diff before staging or committing.
- Stage only intended paths; never use force-add or bypass hooks.
- Do not commit, push, reset, delete, deploy, or migrate unless requested or already
  approved by workflow.
- Prefer reversible operations and preserve recovery path for risky changes.
- Never expose secret values while diagnosing environment configuration.

## Reporting

Final report contains:

1. What changed.
2. Evidence: checks run and results.
3. Remaining risk, blocked item, or required restart—only when present.

Keep report concise. Caveman controls prose compression; Ponytail controls code
minimalism. Do not duplicate their rules here.
