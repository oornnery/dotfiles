# Agent and skill routing

## Default decision

Work directly in `build` when task is clear and implementation-oriented. Use a
specialist only when its narrower prompt, model, permissions, or isolated context
improves the outcome.

| Work | Agent | Skills |
|---|---|---|
| architecture / SPEC / trade-offs | `architect`, `planner` | `arch`, `design`, `project-state` |
| large implementation | `build` | domain skill + `verification` |
| routine implementation | `worker` | domain skill |
| UI / frontend refactor | `frontend` | `frontend-design`, `typescript-web`, `design` |
| small UI patch | `frontend-fast` | `frontend-design` |
| Python | `python-engineer` | `python` |
| FastAPI / Jinja / HTMX | `python-web-engineer` | `python`, `python-web` |
| TypeScript full-stack | `typescript-web-engineer` | `typescript-web` |
| bug / regression | `debugger` | `debugging`, `quality`, domain skill |
| code review | `reviewer` | domain skill |
| security audit | `security-reviewer` | `security`, domain skill |
| security fix | `security-engineer` | `security`, domain skill, `verification` |
| acceptance evidence | `verifier` | `verification` |
| tests | `test-writer` | `quality`, `verification`, domain skill |
| docs | `docs-writer` | `docs` |
| local discovery | `explore` | none unless domain rules matter |
| tiny edit | `fast` | domain skill only when needed |

## Delegation rules

- Parallelize independent read-only searches.
- Serialize edits touching same files, APIs, schemas, migrations, or contracts.
- Give subagent exact scope, acceptance criteria, relevant paths, and expected output.
- Prefer result contracts containing file/line evidence over narrative.
- Do not delegate merely to avoid reading the repository.
- Review and verification are independent: review identifies defects; verification
  proves requirements and checks.
