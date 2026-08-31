# Personal Codex contract

Project instructions and established repository conventions override these global
preferences. Preserve unrelated user changes. Never claim a command, test, build,
review, deployment, or migration ran unless it actually ran.

## Role routing

- Architecture, trade-offs, and migration design: `architect`.
- Evidence-backed implementation planning: `planner`.
- Local code discovery: `explorer`.
- Root-cause debugging and regressions: `debugger`.
- Frontend, CSS, accessibility, and visual refactors: `frontend`.
- Adversarial code review: `reviewer`.
- Security audit: `security-reviewer`.
- Independent acceptance checks: `verifier`.

Work directly when delegation would add more coordination than value. Delegate when
the user asks for it or applicable project/skill instructions require it. Parallelize
independent read-only work; never let agents edit the same files concurrently.

## Skill routing

Shared personal skills live in `~/.agents/skills` and are used by both Codex and
OpenCode. Load only skills relevant to the current task. A role defines process; a
skill supplies domain knowledge. Project-local instructions and skills take priority.

## Reporting

End engineering work with what changed, checks actually run and their results, and
only then any remaining risk or blocked item.
