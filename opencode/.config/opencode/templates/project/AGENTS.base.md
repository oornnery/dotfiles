# {{project-name}} agent guide

## Sources of truth

- Product behavior: `{{path-or-document}}`
- Architecture/contracts: `{{path-or-document}}`
- Development commands: `{{path-or-document}}`
- Current milestone: `.spec/state.md` when present

Read source and tests before editing. Query `.mindmodel/` when present.

## Repository map

- `{{path}}`: {{purpose}}
- `{{path}}`: {{purpose}}

## Commands

- Setup: `{{command}}`
- Test: `{{command}}`
- Lint: `{{command}}`
- Typecheck: `{{command}}`
- Build: `{{command}}`

## Constraints

- Preserve {{critical invariant}}.
- Follow patterns in {{representative path}}.
- Validate {{untrusted boundary}} before domain logic.
- Never commit secrets or generated/private artifacts: {{paths}}.

## Definition of done

- Requested behavior implemented with smallest correct diff.
- Relevant focused and aggregate checks pass.
- Docs/config updated when public behavior or operations changed.
- Remaining risk or blocked evidence stated explicitly.
