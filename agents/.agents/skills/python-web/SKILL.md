---
name: python-web
description: FastAPI, Jinja2, HTMX or Datastar, Pydantic, SQLModel, Alembic, HTML-first UI, auth, forms, persistence, and server-rendered application guidance.
---

# Python web

Prefer repository stack. For new HTML-first apps, default to FastAPI + Jinja2 with
small progressive enhancement. Use HTMX/Datastar/Alpine only where interaction needs it.

## Read

- Route/template/data/auth boundaries: `references/architecture.md`
- Implementation workflow and patterns: `references/implementation.md`
- Final behavior and release checks: `references/checklists.md`

## Rules

- Validate input at route/form/API boundary.
- Keep business logic in services/domain, not routes or templates.
- Keep templates presentation-focused and escape by default.
- Use explicit transactions and migration history.
- Server owns authorization.
- Design success, validation, empty, error, and retry states together.
- Build one vertical slice before broad scaffolding.
- Avoid Celery, Redis, GraphQL, SPA frameworks, and complex build systems unless
  requirements justify them.
