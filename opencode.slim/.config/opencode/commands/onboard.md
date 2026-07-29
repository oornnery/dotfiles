---
name: onboard
description: Project onboarding and environment verification. Use when starting work in a repo, checking the local toolchain, or mapping validation entrypoints before editing.
---

# Onboard

Onboard project before changes. Goal: understand stack, toolchain, validation, repo shape with minimum reading.

## Process

### 1. Detect the project type

Check stack markers:

```bash
ls pyproject.toml package.json Cargo.toml go.mod 2>/dev/null
```

Interpretation:

- `pyproject.toml` -> Python project, usually `uv`
- `package.json` -> frontend or Node project
- both -> fullstack

### 2. Verify the matching toolchain

Check only tools relevant to detected stack. Tool-verify command lists live
in the `python` and `typescript` skills (Onboarding/Validation sections).

RTK, when relevant:

```bash
rtk gain
rtk hook-audit
```

### 3. Install dependencies with the native tool

Prefer stack-native command:

```bash
uv sync
npm install
```

Do not activate virtual environments manually. Use `uv run ...` for Python commands.

### 4. Find validation entrypoints

Check in this order:

1. task aliases in `pyproject.toml` / scripts in `package.json`
2. direct `uv run` / `npm run` commands
3. repo docs or scripts
4. CI config if needed

Default gate order lives in the `python`/`typescript` skill Validation
sections. Security review is explicit, not part of the default order
(`uv run task security`, `npm run security`).

### 5. Inspect project state files

Check for:

- `SPEC.md`, `ARCHITECTURE.md`, `DESIGN.md`, `ROADMAP.md`
- `.state/current.md`, `.state/tasks.md`, `.state/validation.md`, `.state/handoff.md`
- `.mem/context.md`, `.mem/decisions.md`, `.mem/pitfalls.md`

Use the `project-state` skill when these files exist or when work is multi-step.

### 6. Map the project before editing

Identify:

- repo layout and main packages
- architecture style in use
- how config is loaded
- where tests live and how they are grouped
- recent momentum from `git log --oneline -10`

### 7. Suggest the right local skills

Recommend only what fits repo:

- `project-state` for SPEC/ARCHITECTURE/DESIGN/ROADMAP/.state/.mem context
- `verification` for validation gate discovery
- `python` for Python code and tooling
- `typescript` for TS/JS/TSX code and tooling
- `security` for trust boundaries or audits
- `docs` for README, ADRs, or changelogs
- `rtk` for output rewriting and hook troubleshooting

## Output

Summarize:

- project type detected
- toolchain status
- dependency install status
- validation entrypoints found
- project state files found
- repo layout and architecture notes
- suggested local skills

## Constraints

- inspect before editing
- prefer targeted search over broad shell noise
- do not install unrelated tools or dependencies
- report missing tools plainly over guessing
