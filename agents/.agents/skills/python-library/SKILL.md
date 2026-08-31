---
name: python-library
description: Python package and library API design, compatibility, typing, packaging, documentation, deprecation, and release guidance.
---

# Python library

Design from consumer perspective. Keep public surface small, typed, documented, and
stable. Distinguish public/private modules, preserve import paths when required, and use
deprecation before removal. Avoid leaking internal/vendor types. Test supported Python
versions and built artifacts. Validate wheel/sdist contents, imports, entrypoints,
extras, and version metadata.
