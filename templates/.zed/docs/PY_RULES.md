# Workspace Rules: Python Environment, Project Structure, Workflow, Docker, Documentation

These rules standardize environment management (uv/uvx), project structure, lint/format, and documentation across repositories, and are designed to work smoothly with Zed’s Agent Panel and profiles.

## 1. Environment & Dependencies Management
- Always use `uv`/`uvx` to install, update, and remove Python packages.
  - Add dependencies: `uv add <package>` (never edit pyproject.toml manually)
  - Install dependencies: `uv pip install`
  - Run commands in an isolated env: `uv run ...`
  - Build a PyPI package: `uv build`
- Do not use `pip`/`pipx` directly.
- Keep the virtual environment isolated (created and managed by `uv`).
- Avoid global installs.
- Check `utils.py` or `_utils.py` for shared `logger`/`console` and prefer Rich components over raw `print`.

## 2. Project Structure & Directories
Use this layout (inspired by the FastAPI full‑stack template while remaining backend‑only when needed):
```bash

.
├── src/              \# Main code (or the package name)
├── examples/         \# Examples, functional smoke tests, demos
├── docs/             \# General docs and tutorials
├── docker/           \# Docker images, scripts, and env configs
├── CHANGELOG.md      \# All relevant change notes
├── README.md         \# Project overview and quickstart
├── pyproject.toml    \# Project config and dependencies
└── .zed/             \# Zed project settings and optional rules

```

## 3. Workflow & Conventions
- Version control via Git (`git add`, `git commit`, `git push`, etc.).
- Lint/format with Ruff; treat it as the single source for check, sort imports, and format.
- Directory tree visualization before/after changes:
```

tree -a -I '.venv|.git|__pycache__|.ruff_cache|*.egg-info|dist|.pytest_cache|.claude'

```
- After any change in core code, write a short summary in `CHANGELOG.md`.
- Do not create extra .md files for refactors/technical notes; centralize in the changelog.
- Example/functional tests belong in `examples/`.
- Do not add automated tests unless requested.
- All documentation (tutorials, guides, reference) lives under `docs/`.
- Avoid an excess of .md files; deep technical/refactor notes → CHANGELOG.
- Keep the main package’s `__init__.py` version updated as appropriate.

## 4. Docker
- Maintain and update files under `docker/` as environments and deployment requirements evolve.

## 5. README.md
- Keep README.md updated after relevant changes:
- Installation instructions, usage, and main examples.
- Update when structure or dependencies change.

---

## Suggested Improvements
- Automate repetitive steps: define tasks in `pyproject.toml` (e.g., with taskipy) for tree/lint/build/changelog.
- Use pre‑commit hooks with Ruff and `tree` to standardize before commits.
- Add a simple CHANGELOG template (Keep a Changelog style).
- Centralize examples and CLI demos in `examples/` with documented .py scripts.

---

## Operational Checklist
- [ ] Install/update libs only with `uv add`
- [ ] Validate code with Ruff before commit
- [ ] Record changes in `CHANGELOG.md`
- [ ] Keep README.md and docs/ in sync
- [ ] Put examples/demos in `examples/`
- [ ] Update `docker/` as deployment/env changes
- [ ] Inspect directory with `tree -a ...`

---

## Ruff + pre‑commit (examples)

ruff.toml (or under [tool.ruff] in pyproject):
```toml

[lint]
extend-select = ["I"]

[format]
line-ending = "lf"
quote-style = "single"

```

.pre-commit-config.yaml:
```yaml

repos:

- repo: https://github.com/astral-sh/ruff-pre-commit
rev: v0.14.3
hooks:
    - id: ruff-check
args: [--fix]
    - id: ruff-format

```

Install hooks with uvx:
```bash

uvx pre-commit install
uvx pre-commit run -a

```

---

## Task automation via taskipy (pyproject snippets)

pyproject.toml:
```toml

[project]
name = "your-package"
version = "0.1.0"
requires-python = ">=3.12"
dependencies = []

[tool.ruff]
line-length = 100
target-version = "py312"

[tool.ruff.lint]
extend-select = ["I"]

[tool.taskipy.tasks]
tree = "tree -a -I '.venv|.git|__pycache__|.ruff_cache|*.egg-info|dist|.pytest_cache|.claude'"
lint = "uv run ruff check ."
fix = "uv run ruff check . --fix \&\& uv run ruff format ."
build = "uv build"
changelog = "python -c \"print('Update CHANGELOG.md using Keep a Changelog sections')\""

```
