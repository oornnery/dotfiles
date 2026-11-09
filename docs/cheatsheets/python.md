# Python

uv does it all: Pythons, projects, packages and tools. Ruff checks and formats,
basedpyright is the language server in Helix. Setup: `dots install python`.

## A project

| Task | Command |
| ---- | ------- |
| New project | `uv init app` (an app), `uv init --lib lib` (a library) |
| Add a package | `uv add httpx`, dev only: `uv add --dev pytest` |
| Remove | `uv remove httpx` |
| Run | `uv run main.py`, `uv run pytest`: the venv is made and synced on its own |
| Install from the lock | `uv sync` (after a clone) |
| Update | `uv lock --upgrade`, one: `uv lock --upgrade-package httpx` |
| A Python version | `uv python pin 3.13` (writes `.python-version`) |
| A shell in the venv | `source .venv/bin/activate`, or use `uv run` |

## Scripts and tools

| Task | Command |
| ---- | ------- |
| A one-file script with its packages | `uv add --script s.py httpx`, then `uv run s.py` |
| Run a tool once | `uvx ruff check`, `uvx --from httpie http example.com` |
| Install a tool | `uv tool install basedpyright`; list: `uv tool list`; update: `uv tool upgrade --all` |
| Pythons | `uv python list`, `uv python install 3.14` |

## Check and test

| Task | Command |
| ---- | ------- |
| Lint, and fix | `ruff check`, `ruff check --fix` |
| Format | `ruff format` |
| Types | `basedpyright` (Helix shows the same as you type) |
| Tests | `uv run pytest`, one: `pytest -k name`, stop at the first failure: `pytest -x` |

## Common libraries

| For | Library |
| --- | ------- |
| HTTP | `httpx` (sync and async), `requests` |
| Data models, validation | `pydantic` |
| CLI | `typer`, or `argparse` (standard) |
| Terminal output | `rich`; TUIs: `textual` |
| Tables | `polars`, `pandas` |
| Web API | `fastapi` with `uvicorn` |
| Database | `sqlalchemy`, `sqlmodel`; SQLite: `sqlite3` (standard) |
| Tests | `pytest`, `pytest-asyncio` |
| Env files | `python-dotenv` |

## Handy

| Task | Command |
| ---- | ------- |
| Serve a folder | `python -m http.server 8000` |
| Pretty JSON | `python -m json.tool f.json` (or `jq`) |
| A quick REPL with packages | `uv run --with httpx python` |

History and `__pycache__` live outside the project (`env.d/python.sh`).
