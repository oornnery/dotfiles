# Packaging and uv

- Respect existing lockfile and package manager.
- With uv: use `uv sync`, `uv run`, `uv add`, `uv lock`, and `uv build`.
- Keep metadata, Python constraints, extras, entrypoints, and package layout consistent.
- Prefer `src/` layout for distributable libraries when repository already follows it.
- Do not mix application-only dependencies into library runtime requirements.
- Pin tools through project configuration or lockfile, not undocumented globals.
- Validate wheel/sdist contents and import behavior after packaging changes.
- Standalone scripts may use PEP 723 metadata when that improves reproducibility.
