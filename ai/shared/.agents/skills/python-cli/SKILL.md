---
name: python-cli
description: Python CLI and terminal UX with argparse, Typer, Rich, stdout/stderr contracts, exit codes, automation flags, help, and tests.
---

# Python CLI

Use `argparse` for small commands, Typer for multi-command apps when project accepts it,
Rich for presentation, and Textual only for a real TUI.

Separate parsing, orchestration, business logic, and rendering. Every command gets a
clear stdout/stderr split and meaningful exit codes, and dangerous operations ask for
confirmation. Add machine-readable output, verbosity, color policy and a
non-interactive mode when the CLI is scripted or shared. Help must be accurate.
Secrets are never printed. Verify help, success, failure and exit codes, plus
automation mode when it exists.
