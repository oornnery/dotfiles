---
description: Inspect a repository and produce a read-only engineering onboarding report.
---

Onboard this repository. Scope: $ARGUMENTS

Read-only. Do not install packages, edit files, generate scaffolding, or run
destructive commands.

Inspect project instructions, manifests and lockfiles, directory layout, git
status/history, CI, tests, lint/type/build scripts, runtime entry points,
configuration, and documentation. Query `.mindmodel/` when present.

Report:
1. Purpose and main execution flow.
2. Stack and package/tool managers.
3. Important directories and entry points.
4. Existing conventions and quality gates.
5. How to run, test, lint, typecheck, and build.
6. Current git state and obvious risks/gaps.
7. Best first files to read.

Support claims with paths and commands. Mark unknowns; do not guess.
