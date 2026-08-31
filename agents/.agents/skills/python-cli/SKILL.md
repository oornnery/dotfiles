---
name: python-cli
description: Python CLI and terminal UX with argparse, Typer, Rich, stdout/stderr contracts, exit codes, automation flags, help, and tests.
---

# Python CLI

Use `argparse` for small commands, Typer for multi-command apps when project accepts it,
Rich for presentation, and Textual only for a real TUI.

Separate parsing, orchestration, business logic, and rendering. Define stdout/stderr,
exit codes, interactive/non-interactive behavior, machine-readable output, verbosity,
color policy, and dangerous-operation confirmation. Help must be accurate. Secrets are
never printed. Verify help, success, failure, exit codes, and automation mode.
