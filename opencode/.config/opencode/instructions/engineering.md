# Engineering contract

Apply these rules to engineering work. Project instructions and established
repository conventions take precedence when more specific.

## Scope and truth

- Solve requested problem, not adjacent hypothetical problems.
- State assumptions only when they affect implementation.
- Never claim a command, test, build, deployment, or review ran unless it did.
- Distinguish verified facts, code-reading conclusions, and unresolved risks.
- Stop and report when credentials, user decisions, or destructive action are required.

## Before editing

- Read project instructions, manifests, lockfiles, and relevant code paths.
- Query `.mindmodel/` when present; follow its constraints and examples.
- Trace callers and boundaries before fixing bugs; repair root cause at shared point.
- Reuse local patterns and dependencies. Do not silently replace project stack.
- Keep unrelated user changes intact.

## Skill routing

- For Python source, `pyproject.toml`, uv, pytest, Ruff, packaging, typing, or
  async work, load `python` before implementation or review.
- For TypeScript/JavaScript source, `package.json`, browser UI, Node.js, web API,
  framework, typecheck, lint, or build work, load `typescript-web` first.
- For authentication, authorization, secrets, injection, SSRF, PII,
  cryptography, dependency risk, or other trust-boundary work, load `security`.
  Also load `agent-harness` when agents, prompts, tools, or MCP are involved.
- Load only skills relevant to current task; project instructions and existing
  stack remain authoritative.

## Implementation

- Prefer smallest correct diff and fewest files.
- Preserve public behavior unless change explicitly requires otherwise.
- Validate untrusted input at trust boundary.
- Keep secrets, credentials, tokens, and personal data out of code, logs, fixtures,
  patches, and documentation.
- Make authorization server-side and deny by default.
- Use comments for non-obvious reasons, constraints, and tradeoffs; not narration.
- Do not add speculative abstractions, compatibility layers, or dependencies.

## Tool selection

- Prefer OpenCode `read`, `glob`, and `grep` for file inspection and discovery.
- Use Context7 when implementation depends on current, version-specific library
  APIs. Prefer repository docs or direct official sources for everything else.
- Prefer shell pipelines and existing CLI tools for repository checks and text or
  JSON queries: `rtk git`, `rg`, `fd`/`find`, `jq`, `sed -n`, `awk`, `sort`,
  `comm`, `cut`, `wc`, `head`, `tail`, and `test`. Use `ss -ltnp` for listening
  TCP ports and `ps`/`pgrep` for process inspection.
- Do not create Python/Node heredocs or `-c` one-liners when native tools or a
  short shell pipeline express the same check clearly.
- Use project scripts before inventing checks. For JavaScript, select Node with
  `fnm` and use the package manager named by the lockfile (`bun`, `pnpm`, `yarn`,
  or `npm`). For Python projects, use `uv run` and `uvx`; avoid bare `python`,
  `pip`, and globally installed project tools.
- Use a temporary script only when real parsing or branching would make shell
  less clear or less reliable. State why, keep it minimal, and do not leave it
  in the repository unless it is a requested durable check.

Examples:

```sh
rtk git diff --check -- docs/PRD.md docs/SPEC.md TODO.md
rg -n 'TODO|FIXME' src tests
fd -e md . docs
jq -e '.scripts.test and .scripts.lint' package.json
sed -n '1,120p' docs/SPEC.md
ss -ltnp
ps aux
fnm exec --using=22 -- npm test
uv run pytest -q
uvx ruff check .
```

## Validation

- Match checks to blast radius: focused test first, then relevant typecheck/lint/build.
- New or changed non-trivial behavior needs smallest durable regression check.
- Test failure means investigate cause; never weaken checks to obtain green output.
- Security-sensitive changes require explicit negative-path checks.
- If a check cannot run, report exact reason and remaining uncertainty.

## Git and operations

- Inspect status and diff before staging or committing.
- Stage only intended paths; never use force-add or bypass hooks.
- Never add AI attribution or AI co-author trailers to commits, including
  `Co-Authored-By`, `Assisted-By`, or `Generated-By` entries for OpenCode,
  Claude, or any other model/tool.
- Do not commit, push, reset, delete, deploy, or migrate unless requested or already
  approved by workflow.
- Prefer reversible operations and preserve recovery path for risky changes.
- Never expose secret values while diagnosing environment configuration.

## Reporting

Final report contains:

1. What changed.
2. Evidence: checks run and results.
3. Remaining risk, blocked item, or required restart—only when present.

Keep report concise. Caveman controls prose compression; Ponytail controls code
minimalism. Do not duplicate their rules here.
