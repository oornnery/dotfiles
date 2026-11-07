# AI map

Everything from the old setup, to review. Nothing here is linked: this folder is
nested on purpose, so `dots stow` does not see it and no tool reads it.

To turn one on, after reviewing it (it may conflict with your current config):

```bash
stow --no-folding -d ~/dotfiles/ai -t ~ claude
```

Packages: `claude`, `codex`, `opencode`, `pi`, `shared` (skills read by several tools).

## Caveman and RTK

| What | Path |
| --- | --- |
| Caveman skills | `claude/.claude/skills/caveman*/` |
| Caveman output style | `claude/.claude/output-styles/caveman.md` |
| RTK instructions | `claude/.claude/RTK.md` |
| Claude hooks and plugins | `claude/.claude/settings.json` |
| MCP servers, including cavemem | `claude/.claude/mcp/servers.json` |

The tools themselves (rtk, cavemem) are not installed by this folder.

## Claude skills

| Name | Path | What it does |
| --- | --- | --- |
| `caveman` | `claude/.claude/skills/caveman/` | Ultra-compressed communication mode. Cuts output tokens 65% (measured) by speaking like caveman |
| `caveman-commit` | `claude/.claude/skills/caveman-commit/` | Ultra-compressed commit message generator. Cuts noise from commit messages while preserving |
| `caveman-compress` | `claude/.claude/skills/caveman-compress/` | Compress natural language memory files (CLAUDE.md, todos, preferences) into caveman format |
| `caveman-help` | `claude/.claude/skills/caveman-help/` | Quick-reference card for all caveman modes, skills, and commands. |
| `caveman-review` | `claude/.claude/skills/caveman-review/` | Ultra-compressed code review comments. Cuts noise from PR feedback while preserving |
| `debug` | `claude/.claude/skills/debug/` | Investigate a failure and find its root cause. Applies a fix only when the request asks for one. |
| `deep` | `claude/.claude/skills/deep/` | Hand a complex, cross-cutting task or migration to the deep agent for end-to-end implementation. |
| `docs` | `claude/.claude/skills/docs/` | Update documentation from verified code and configuration, never from assumptions. |
| `fast` | `claude/.claude/skills/fast/` | Handle a small, bounded task with minimal overhead - quick edits, docs, mechanical changes. |
| `frontend` | `claude/.claude/skills/frontend/` | Design or improve a UI using the relevant impeccable playbook, with browser verification. |
| `implement` | `claude/.claude/skills/implement/` | Implement the requested task completely, with appropriate verification. Use for ordinary feature ... |
| `plan` | `claude/.claude/skills/plan/` | Plan a task from repository evidence without editing anything. |
| `project-bootstrap` | `claude/.claude/skills/project-bootstrap/` | Create a project foundation from a brief or an existing plan, using only the files, dependencies ... |
| `safe-commit` | `claude/.claude/skills/safe-commit/` | Create a reviewed Conventional Commit from the intended changes, without pushing. |
| `shape` | `claude/.claude/skills/shape/` | Define product scope and requirements, and write the project documents that were actually asked for. |
| `tests` | `claude/.claude/skills/tests/` | Add meaningful tests for a behavior using the repository's existing test setup. |
| `verify` | `claude/.claude/skills/verify/` | Independently verify requirements and implementation claims, returning PASS, FAIL or BLOCKED with... |

## Claude agents

| Name | Path | What it does |
| --- | --- | --- |
| `debugger` | `claude/.claude/agents/debugger.md` | Root-cause diagnosis and requested fixes for difficult bugs. Use when something fails and the cau... |
| `deep` | `claude/.claude/agents/deep.md` | Difficult implementation, cross-cutting changes, and complex migrations. Use when a task spans se... |
| `fast` | `claude/.claude/agents/fast.md` | Quick answers, small edits, documentation, and mechanical changes. Use for clear, bounded work th... |
| `frontend` | `claude/.claude/agents/frontend.md` | UI design and implementation using the impeccable playbooks. Use for visual quality, layout, desi... |
| `reviewer` | `claude/.claude/agents/reviewer.md` | Read-only review of actual diffs, callers and tests. Use for a code review that must not edit any... |
| `security-reviewer` | `claude/.claude/agents/security-reviewer.md` | Read-only security review of reachable attack paths. Use when work touches auth, secrets, input h... |
| `shape` | `claude/.claude/agents/shape.md` | Define product scope, requirements and useful project documents. Use for product definition and b... |
| `verifier` | `claude/.claude/agents/verifier.md` | Independently verifies requirements and implementation claims, returning PASS, FAIL, or BLOCKED w... |

## Shared skills

| Name | Path | What it does |
| --- | --- | --- |
| `archify` | `shared/.agents/skills/archify/` | Create polished, validated architecture, workflow, sequence, data-flow, and lifecycle/state diagr... |
| `impeccable` | `shared/.agents/skills/impeccable/` | Use when the user wants to design, redesign, shape, critique, audit, polish, clarify, distill, ha... |
| `no-ai-slop` | `shared/.agents/skills/no-ai-slop/` | Edit drafts into sharper, more human writing while preserving the writer's personal voice, or det... |
| `project-state` | `shared/.agents/skills/project-state/` | Record durable project decisions or handoff context when the user needs work to continue across s... |
| `python` | `shared/.agents/skills/python/` | Modern Python implementation, debugging, typing, packaging, asyncio, testing, and uv guidance. Us... |
| `python-cli` | `shared/.agents/skills/python-cli/` | Python CLI and terminal UX with argparse, Typer, Rich, stdout/stderr contracts, exit codes, autom... |
| `python-library` | `shared/.agents/skills/python-library/` | Python package and library API design, compatibility, typing, packaging, documentation, deprecati... |
| `python-web` | `shared/.agents/skills/python-web/` | FastAPI, Jinja2, HTMX or Datastar, Pydantic, SQLModel, Alembic, HTML-first UI, auth, forms, persi... |
| `security` | `shared/.agents/skills/security/` | Threat modeling and secure implementation for auth, authorization, secrets, injection, SSRF, file... |
| `typescript-web` | `shared/.agents/skills/typescript-web/` | TypeScript and JavaScript full-stack guidance for browser UI, Hono, JSX/TSX, React, Preact, Solid... |

## Codex agents

| Name | Path | What it does |
| --- | --- | --- |
| `architect` | `codex/.codex/agents/architect.toml` |  |
| `debugger` | `codex/.codex/agents/debugger.toml` |  |
| `explorer` | `codex/.codex/agents/explorer.toml` |  |
| `fast` | `codex/.codex/agents/fast.toml` |  |
| `frontend` | `codex/.codex/agents/frontend.toml` |  |
| `planner` | `codex/.codex/agents/planner.toml` |  |
| `reviewer` | `codex/.codex/agents/reviewer.toml` |  |
| `security-reviewer` | `codex/.codex/agents/security-reviewer.toml` |  |
| `verifier` | `codex/.codex/agents/verifier.toml` |  |
| `worker` | `codex/.codex/agents/worker.toml` |  |

## OpenCode agents

| Name | Path | What it does |
| --- | --- | --- |
| `build` | `opencode/.config/opencode/agents/build.md` | Daily implementation, using existing project conventions. |
| `debugger` | `opencode/.config/opencode/agents/debugger.md` | Root-cause diagnosis and requested fixes for difficult bugs. |
| `deep` | `opencode/.config/opencode/agents/deep.md` | Difficult implementation, cross-cutting changes, and complex migrations. |
| `explore` | `opencode/.config/opencode/agents/explore.md` | Fast read-only discovery with file and symbol evidence. |
| `fast` | `opencode/.config/opencode/agents/fast.md` | Quick answers, small edits, documentation, and mechanical changes. |
| `frontend` | `opencode/.config/opencode/agents/frontend.md` | UI design and implementation using Impeccable. |
| `plan` | `opencode/.config/opencode/agents/plan.md` | Read-only technical planning and architecture trade-offs. |
| `reviewer` | `opencode/.config/opencode/agents/reviewer.md` | Read-only review of actual diffs, callers and tests. |
| `security-reviewer` | `opencode/.config/opencode/agents/security-reviewer.md` | Read-only security review of reachable attack paths. |
| `shape` | `opencode/.config/opencode/agents/shape.md` | Define product scope, requirements and useful project documents. |
| `verifier` | `opencode/.config/opencode/agents/verifier.md` | Independently verifies requirements and implementation claims, returning PASS, FAIL, or BLOCKED w... |

## OpenCode commands

| Name | Path | What it does |
| --- | --- | --- |
| `debug` | `opencode/.config/opencode/commands/debug.md` | Investigate this issue. Apply a fix when the request asks for one. |
| `deep` | `opencode/.config/opencode/commands/deep.md` | Complete this complex task, including integration and relevant verification. |
| `docs` | `opencode/.config/opencode/commands/docs.md` | Update documentation from verified code and configuration. |
| `fast` | `opencode/.config/opencode/commands/fast.md` | Handle this bounded task with minimal overhead. |
| `frontend` | `opencode/.config/opencode/commands/frontend.md` | Design or improve this UI using the relevant Impeccable playbook. |
| `impeccable` | `opencode/.config/opencode/commands/impeccable.md` | Use the impeccable skill for the requested command and target. |
| `implement` | `opencode/.config/opencode/commands/implement.md` | Implement the requested task completely, with appropriate verification. |
| `plan` | `opencode/.config/opencode/commands/plan.md` | Plan this task from repository evidence without editing. |
| `project-bootstrap` | `opencode/.config/opencode/commands/project-bootstrap.md` | Create the requested project foundation from the brief or existing plan. Use only the needed file... |
| `review` | `opencode/.config/opencode/commands/review.md` | Review this scope; if empty, review the current diff. Do not edit. |
| `safe-commit` | `opencode/.config/opencode/commands/safe-commit.md` | Create a reviewed Conventional Commit from intended changes without pushing. |
| `security-review` | `opencode/.config/opencode/commands/security-review.md` | Audit this scope for concrete security issues. Do not edit. |
| `shape` | `opencode/.config/opencode/commands/shape.md` | Define the product scope and create or update useful project documents as requested. |
| `tests` | `opencode/.config/opencode/commands/tests.md` | Add meaningful tests for the requested behavior using the existing test setup. |
| `verify` | `opencode/.config/opencode/commands/verify.md` | Verify requirements and implementation claims with evidence. |

## Pi agents

| Name | Path | What it does |
| --- | --- | --- |
| `build` | `pi/.pi/agent/agents/build.md` | Daily implementation, using existing project conventions. |
| `debugger` | `pi/.pi/agent/agents/debugger.md` | Root-cause diagnosis and requested fixes for difficult bugs. |
| `deep` | `pi/.pi/agent/agents/deep.md` | Difficult implementation, cross-cutting changes, and complex migrations. |
| `explore` | `pi/.pi/agent/agents/explore.md` | Fast read-only discovery with file and symbol evidence. |
| `fast` | `pi/.pi/agent/agents/fast.md` | Quick answers, small edits, documentation, and mechanical changes. |
| `frontend` | `pi/.pi/agent/agents/frontend.md` | UI design and implementation using Impeccable. |
| `plan` | `pi/.pi/agent/agents/plan.md` | Read-only technical planning and architecture trade-offs. |
| `reviewer` | `pi/.pi/agent/agents/reviewer.md` | Read-only review of actual diffs, callers and tests. |
| `security-reviewer` | `pi/.pi/agent/agents/security-reviewer.md` | Read-only security review of reachable attack paths. |
| `shape` | `pi/.pi/agent/agents/shape.md` | Define product scope, requirements and useful project documents. |
| `verifier` | `pi/.pi/agent/agents/verifier.md` | Independently verifies requirements and implementation claims, returning PASS, FAIL, or BLOCKED w... |

## Pi prompts

| Name | Path | What it does |
| --- | --- | --- |
| `debug` | `pi/.pi/agent/prompts/debug.md` | Investigate this issue. Apply a fix when the request asks for one. |
| `deep` | `pi/.pi/agent/prompts/deep.md` | Complete this complex task, including integration and relevant verification. |
| `docs` | `pi/.pi/agent/prompts/docs.md` | Update documentation from verified code and configuration. |
| `fast` | `pi/.pi/agent/prompts/fast.md` | Handle this bounded task with minimal overhead. |
| `frontend` | `pi/.pi/agent/prompts/frontend.md` | Design or improve this UI using the relevant Impeccable playbook. |
| `impeccable` | `pi/.pi/agent/prompts/impeccable.md` | Use the impeccable skill for the requested command and target. |
| `implement` | `pi/.pi/agent/prompts/implement.md` | Implement the requested task completely, with appropriate verification. |
| `plan` | `pi/.pi/agent/prompts/plan.md` | Plan this task from repository evidence without editing. |
| `project-bootstrap` | `pi/.pi/agent/prompts/project-bootstrap.md` | Create the requested project foundation from the brief or existing plan. Use only the needed file... |
| `review` | `pi/.pi/agent/prompts/review.md` | Review this scope; if empty, review the current diff. Do not edit. |
| `safe-commit` | `pi/.pi/agent/prompts/safe-commit.md` | Create a reviewed Conventional Commit from intended changes without pushing. |
| `security-review` | `pi/.pi/agent/prompts/security-review.md` | Audit this scope for concrete security issues. Do not edit. |
| `shape` | `pi/.pi/agent/prompts/shape.md` | Define the product scope and create or update useful project documents as requested. |
| `tests` | `pi/.pi/agent/prompts/tests.md` | Add meaningful tests for the requested behavior using the existing test setup. |
| `verify` | `pi/.pi/agent/prompts/verify.md` | Verify requirements and implementation claims with evidence. |

## Other files

| File | What it is |
| --- | --- |
| `env.example`, `env-README.md` | API keys template; the real file is `~/.config/ai/env` |
| `scripts/` | Old setup and validation scripts, not reviewed |

`shared/.agents/skills/archify/examples` (4 MB of demo pages) was left in the old repo.
