---
name: cicd
description: CI/CD workflow design and review for GitHub Actions, permissions, matrices, caching, artifacts, releases, deployments, and supply-chain safety.
---

# CI/CD

- Pin actions/dependencies according to repository policy.
- Set least-privilege workflow/job permissions.
- Separate untrusted PR code from secrets and privileged events.
- Make cache keys include dependency/lockfile inputs.
- Keep matrices purposeful and failures visible.
- Upload useful artifacts/logs with retention limits.
- Make deploy/release idempotent, gated, observable, and recoverable.
- Reuse local project commands so CI and developer checks match.
- Never print secrets or interpolate untrusted input into shell.
