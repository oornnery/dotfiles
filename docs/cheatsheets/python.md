# Python + Pip + Uv Cheatsheet

## Commands

| Command                     | What it does                          |
| --------------------------- | ------------------------------------- |
| `python3 --version`         | Show Python version                   |
| `python3 -m venv .venv`     | Create virtual environment            |
| `source .venv/bin/activate` | Activate virtual environment          |
| `pip install <pkg>`         | Install Python package                |
| `uv venv`                   | Create venv via uv                    |
| `uv pip install <pkg>`      | Install package with uv pip interface |
| `uvx ruff check .`          | Run Ruff linter in current project    |
| `uvx ruff format .`         | Format Python files with Ruff         |
| `uvx ty check`              | Run ty type checker                   |
| `rumdl check .`             | Lint Markdown files                   |
| `rumdl fmt .`               | Format/fix Markdown files             |
| `uv pip list`               | List installed packages in env        |
| `uv pip freeze`             | Export dependency list                |
| `uvx ruff check . --fix`    | Auto-fix lint issues when possible    |

## Shortcuts

| Shortcut         | Action                                         |
| ---------------- | ---------------------------------------------- |
| `deactivate`     | Exit current virtual environment               |
| `python -m pip`  | Ensures pip targets current Python interpreter |
| `uvx <tool> ...` | Run Python tools without global install        |

## Examples

```bash
# Create and activate env
python3 -m venv .venv
source .venv/bin/activate

# Install deps with uv
uv pip install -r requirements.txt

# Quality pass
uvx ruff check .
uvx ruff format .
uvx ty check
```

## Tips

| Tip                                         | Why it helps                                   |
| ------------------------------------------- | ---------------------------------------------- |
| Use virtual environments per project        | Isolated dependencies                          |
| Use `uv` for speed                          | Faster env and dependency operations           |
| Use `ruff` for lint + format                | Replaces multiple tools with one fast workflow |
| Use `ty` for static typing checks           | Catches type issues earlier                    |
| Use `rumdl` in docs repos                   | Keeps Markdown clean and consistent            |
| Pin dependencies in requirements/lock files | Reproducible setups                            |
| Keep lint + type checks in CI               | Prevent regressions in team workflows          |

## Recommended workflow

| Step             | Command             | Purpose                                |
| ---------------- | ------------------- | -------------------------------------- |
| 1. Format docs   | `uvx rumdl fmt .`   | Auto-format Markdown, including tables |
| 2. Check docs    | `uvx rumdl check .` | Validate Markdown rules                |
| 3. Lint Python   | `uvx ruff check .`  | Catch style and quality issues         |
| 4. Format Python | `uvx ruff format .` | Apply Python formatting                |
| 5. Type-check    | `uvx ty check`      | Validate Python typing                 |
