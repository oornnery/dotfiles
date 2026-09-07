---
name: python-library
description: Python package and library API design, compatibility, typing, packaging, documentation, deprecation, and release guidance.
---

# Python library

Design from consumer perspective. Keep public surface small, typed, documented, and
stable. Distinguish public/private modules, preserve import paths when required, and use
deprecation before removal. Avoid leaking internal/vendor types. For packaging or
release changes, validate built artifacts, imports, entrypoints, extras and metadata
on the supported Python versions. For ordinary code changes, check affected behavior.
