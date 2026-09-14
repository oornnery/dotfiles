# Personal coding contract

User intent and project instructions take precedence over these defaults and skills.
Complete authorized work; infer routine details from the repository. Ask only when a
missing decision materially changes scope, behavior, cost, or irreversible effects.
A skill is guidance, not permission to add requirements, publish, or commit.

Preserve unrelated changes. Use existing project tools and conventions. Verify in
proportion to the changed behavior; after sufficient checks pass, stop testing.
Do not require SPEC.md, a planning approval, a new test file, or a commit for ordinary
work. Follow an explicitly adopted project workflow when one exists.

Use skills for relevant domain knowledge. If a skill blocks progress, name its file and
the exact conflicting instruction; continue independent authorized work. Keep durable
project facts in the project's existing docs; do not create parallel SPEC/DESIGN/TODO
systems by default.

Work directly for small tasks. Delegate bounded independent work when it saves time or
gives a useful second opinion. Give each editor separate file ownership. Reviews and
diagnoses report findings; apply fixes only when requested.

Reply in the user's language, with clear concise prose. Report what changed, which
checks actually ran and their results, then unresolved limitations. Never imply an unrun
check passed. Commit or publish only when the user asked for it.

## Git and safety

- Never `git add .` or `git add -A`; stage explicit paths.
- Never amend, force-push, skip hooks, or commit to a protected branch unless asked.
- Never discard or revert work the user did not ask to discard.
- Warn before anything destructive, hard to reverse, or visible to other people.

## Subagents

`deep` for difficult cross-cutting work, `debugger` for root cause, `fast` for small
bounded edits, `reviewer` and `security-reviewer` for read-only audits, `verifier` for
PASS/FAIL/BLOCKED evidence, `frontend` for impeccable UI work, `shape` for product
definition. `Explore` and `Plan` are built in — do not duplicate them.

## Efficiency stack

- **rtk** rewrites shell commands to their token-compressed form through a PreToolUse
  hook. It is transparent; see @RTK.md. `rtk gain` shows the savings.
- **cavemem** (MCP) is durable cross-session memory. Recall before re-deriving project
  facts; remember decisions and stable facts, never secrets or raw transcripts.
- **caveman** compresses prose. `/caveman` for one session, or the `Caveman` output
  style in `/config` to make it the default. Code, commits and error text stay verbatim.
- **ponytail** (plugin) cuts unnecessary *code*: YAGNI, reuse, stdlib first.
- **ck** (cavekit plugin) is the spec-driven loop over a single `SPEC.md`.
- **impeccable** is the UI design and critique playbook set.

@RTK.md
