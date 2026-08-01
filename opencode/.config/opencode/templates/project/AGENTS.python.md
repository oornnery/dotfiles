## Python overlay

- Supported Python: `{{version}}`; package manager: `{{uv|poetry|pip}}`.
- Source: `{{path}}`; tests: `{{path}}`.
- Use configured Ruff/type checker/test runner; do not introduce parallel tooling.
- Keep I/O and async boundaries explicit; validate external data at adapters.
- Commands:
  - Focused test: `{{command}}`
  - Full test: `{{command}}`
  - Lint/type: `{{command}}`
