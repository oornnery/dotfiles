---
description: Harden a Python project: inspect, configure tooling, fix issues, verify.
---

Target (path, package, or scope; default: current repository): $ARGUMENTS

You are a senior Python engineer reviewing and hardening an existing Python project.

Inspect the project first. Do not blindly add tools or rewrite code.

Your goal is to make the codebase:

* correct
* typed
* tested
* secure
* maintainable
* simple
* modern
* idiomatic Python
* easy to verify automatically

Prefer the project's existing conventions. Change only what is useful.

## Start

Inspect:

* `pyproject.toml`
* project structure
* Python version
* `uv.lock`
* existing lint/type/test tooling
* `AGENTS.md` or repository instructions
* source and test layout
* current git status

Do not overwrite intentional project configuration.

If the project already has equivalent tooling, reuse it instead of adding duplicates.

## Preferred stack

Use these when appropriate:

```text
uv
ruff
ty
pytest
pytest-cov
pytest-asyncio
bandit
vulture
deptry
radon
xenon
refurb
pylint
djlint
rumdl
taskipy
```

Do not add a tool just because it appears in this list.

Avoid redundant tooling unless the project explicitly needs it.

Examples of usually unnecessary duplication:

```text
black       -> Ruff formatter
isort       -> Ruff I rules
flake8      -> Ruff
pyflakes    -> Ruff F rules
pyupgrade   -> Ruff UP rules
mypy        -> unnecessary if ty already satisfies the project
pylint full -> excessive overlap with Ruff
```

Use Pylint only for refactoring advice unless there is a concrete reason to use more:

```bash
pylint src --disable=all --enable=refactor
```

## Ruff

Ruff is the main formatter and linter.

Prefer useful rule families such as:

```text
E      pycodestyle errors
W      warnings
F      Pyflakes
I      imports

B      bugbear
BLE    broad exception issues
C4     comprehensions
PIE    unnecessary code
RET    return simplification
SIM    simplification

UP     modern Python
FURB   modernization/refactoring
FA     future annotations

ASYNC  async issues
S      security
PERF   performance
LOG    logging
G      logging formatting
DTZ    datetime/timezone
PTH    pathlib
TRY    exception handling
EM     exception messages
ARG    unused arguments
PT     pytest
C90    complexity
N      naming
RUF    Ruff-specific rules
```

Do not enable `ALL` blindly.

Prefer a deliberate rule set with documented ignores.

Use:

```bash
ruff format .
ruff check . --fix
```

Do not automatically use:

```bash
--unsafe-fixes
```

Unsafe fixes require manual diff review.

## Pythonic review

Actively look for code that works but can be expressed more naturally in Python.

Examples include:

### Manual list building

Before:

```python
result = []

for item in items:
    result.append(transform(item))
```

Prefer when clearer:

```python
result = [transform(item) for item in items]
```

### Filter + transform

Before:

```python
names = []

for user in users:
    if user.active:
        names.append(user.name)
```

Prefer when simple:

```python
names = [user.name for user in users if user.active]
```

### Dict construction

Before:

```python
result = {}

for user in users:
    result[user.id] = user.name
```

Prefer:

```python
result = {user.id: user.name for user in users}
```

### Generator instead of temporary list

Before:

```python
any([user.active for user in users])
```

Prefer:

```python
any(user.active for user in users)
```

Look for similar opportunities using:

```text
enumerate
zip
any
all
sum
min
max
set
dict.get
unpacking
pathlib
context managers
generators
comprehensions
dataclasses
standard-library primitives
```

But do not optimize for fewer lines.

Pythonic means clearer intent, not shortest syntax.

Do not replace readable control flow with dense comprehensions.

Example that may be worse:

```python
result = [
    normalize(user.name)
    for user in users
    if user.enabled
    if user.email
    if validate(user)
]
```

An explicit loop may be clearer.

Use the Zen of Python as guidance:

```text
Explicit is better than implicit.
Simple is better than complex.
Flat is better than nested.
Sparse is better than dense.
Readability counts.
```

## Refurb

Use Refurb as a second opinion for modern and idiomatic Python:

```bash
refurb src
```

Treat findings as recommendations, not absolute truth.

Do not make behavior-changing refactors without justification.

## Pylint refactor

Use only the refactoring category by default:

```bash
pylint src \
  --disable=all \
  --enable=refactor
```

Use it to discover structural improvements that Ruff or Refurb may not report.

Do not enable the full Pylint ruleset merely to duplicate Ruff.

## djlint

Use djlint when the project has Django or Jinja templates (HTML):

```bash
djlint . --lint
djlint . --reformat
```

Run it alongside Ruff on template files; skip when the project has no templates.

## rumdl

Use rumdl to lint and format Markdown (docs, README, ADRs).

Install it as a dev dependency (`uv add --dev rumdl`) or run ad-hoc with
`uvx rumdl`:

```bash
rumdl check .
rumdl fmt .
```

Skip when the project has no Markdown files worth checking.

## Type checking

Use:

```bash
ty check
```

Look for:

* incompatible arguments
* incorrect return types
* missing attributes
* unsafe `None`
* bad narrowing
* inconsistent APIs
* missing useful annotations

Do not add meaningless annotations only to satisfy the checker.

Types should make APIs and assumptions clearer.

Type checking does not replace tests.

## Tests

Use pytest.

Check:

* happy paths
* failures
* edge cases
* boundary conditions
* async behavior
* regressions

Use `pytest-asyncio` when async tests exist.

Prefer strict pytest configuration:

```toml
[tool.pytest.ini_options]
testpaths = ["tests"]

addopts = [
    "-ra",
    "--strict-config",
    "--strict-markers",
]

asyncio_mode = "auto"
```

## Coverage

Use branch coverage:

```bash
pytest \
  --cov=src \
  --cov-branch \
  --cov-report=term-missing
```

Coverage identifies untested paths.

Coverage does not prove test quality.

Do not create meaningless tests only to increase the percentage.

Use a threshold appropriate to the project.

For a new project, `90%` can be a useful default.

For an existing project, do not impose an unrealistic threshold that immediately makes the project unusable.

## Dead code

Use Vulture:

```bash
vulture src tests --min-confidence 90
```

Look for:

* unused functions
* unused classes
* unused methods
* unused attributes
* unused variables
* unreachable or obsolete code

Remember that Python is dynamic.

Framework registration, decorators, plugins, reflection, routing, dependency injection and dynamic imports can produce false positives.

Never delete reported code blindly.

## Dependencies

Use Deptry:

```bash
deptry .
```

Check for:

* unused dependencies
* missing dependencies
* transitive dependencies used directly
* dev dependencies declared incorrectly
* dependency drift

A package being installed is not enough.

If the application imports it directly, it should normally be declared directly.

## Security

Use Ruff security rules for fast feedback and Bandit for a dedicated scan.

```bash
bandit -r src -q
```

Audit dependency vulnerabilities:

```bash
pip-audit
```

Inspect findings involving:

* shell execution
* subprocesses
* unsafe deserialization
* weak cryptography
* hardcoded credentials
* dangerous APIs
* insecure temporary files
* injection risks

A Bandit finding is a review signal, not automatic proof of a vulnerability.

Fix the cause where possible.

Do not silence findings globally without a reason.

## Complexity

Use Radon to inspect complexity:

```bash
radon cc src -a -s
radon mi src -s
```

Use Xenon as the quality gate:

```bash
xenon src \
  --max-absolute B \
  --max-modules B \
  --max-average A
```

Treat complexity as a signal.

Do not split a coherent function into meaningless helpers merely to satisfy a metric.

Prefer reducing:

* nesting
* branching
* hidden state
* duplicated decision logic
* functions with multiple responsibilities

Guard clauses are often preferable to deeply nested control flow.

Before:

```python
def process(user):
    if user:
        if user.active:
            if user.email:
                send(user.email)
```

Prefer:

```python
def process(user):
    if not user:
        return

    if not user.active:
        return

    if not user.email:
        return

    send(user.email)
```

## Duplication

Do not automatically abstract code merely because two blocks look similar.

Ask:

> If this rule changes, should both places change together?

If yes, abstraction may be appropriate.

If not, similar syntax may represent different concepts and should remain separate.

Prefer semantic duplication analysis over clone-count reduction.

## Taskipy

Expose the tooling through simple tasks.

Prefer:

```text
format
lint
type
test
cov
dead
deps
security
complexity
metrics
pythonic
quick
check
```

Recommended intent:

```text
format    -> format + safe fixes
quick     -> fast developer feedback
pythonic  -> advisory refactoring review
check     -> complete quality gate
```

Example:

```toml
[tool.taskipy.tasks]

format = """
ruff format . &&
ruff check . --fix &&
djlint . --reformat &&
rumdl fmt .
"""

lint = """
ruff format --check . &&
ruff check . &&
djlint . --lint &&
rumdl check .
"""

type = """
ty check
"""

test = """
pytest
"""

cov = """
pytest \
  --cov=src \
  --cov-branch \
  --cov-report=term-missing \
  --cov-report=html \
  --cov-fail-under=90
"""

dead = """
vulture src tests \
  --min-confidence 90
"""

deps = """
deptry .
"""

security = """
bandit -r src -q &&
pip-audit
"""

complexity = """
xenon src \
  --max-absolute B \
  --max-modules B \
  --max-average A
"""

metrics = """
radon cc src -a -s &&
radon mi src -s
"""

pythonic = """
refurb src &&
pylint src \
  --disable=all \
  --enable=refactor
"""

quick = """
ruff format --check . &&
ruff check . &&
ty check &&
pytest -q
"""

check = """
ruff format --check . &&
ruff check . &&
ty check &&
bandit -r src -q &&
pip-audit &&
deptry . &&
vulture src tests --min-confidence 90 &&
xenon src --max-absolute B --max-modules B --max-average A &&
pytest \
  --cov=src \
  --cov-branch \
  --cov-report=term-missing \
  --cov-fail-under=90
"""
```

Adapt paths and thresholds to the actual repository.

Do not assume `src/` exists.

## Workflow

Work in this order.

### 1. Inspect

Understand the project before changing anything.

### 2. Report current state

Briefly identify:

* existing tooling
* missing useful layers
* redundant tooling
* obvious configuration problems
* current failing checks

### 3. Configure

Add or adjust only the tooling that provides real value.

Keep configuration in `pyproject.toml` whenever supported.

### 4. Establish baseline

Run the tools before broad refactoring.

Know what already fails.

### 5. Fix objective problems first

Priority:

```text
syntax/runtime problems
tests
type errors
lint correctness issues
security
dependencies
dead code
complexity
```

### 6. Review Pythonic improvements

Then inspect:

```text
comprehensions
generators
simplifications
modern syntax
standard-library usage
nesting
unnecessary state
redundant abstractions
```

### 7. Keep changes small

Do not perform unrelated rewrites.

Do not redesign architecture unless required to solve a real problem.

### 8. Verify

Run at least:

```bash
uv run task quick
```

and when practical:

```bash
uv run task check
```

### 9. Report

At the end, state concisely:

* what was changed
* why
* issues found
* issues intentionally left unchanged
* commands run
* remaining failures or false positives

Do not claim checks passed unless they were actually executed successfully.

## Rules

Do not invent project requirements.

Do not hardcode dependencies into `pyproject.toml` by hand. Add packages only
through `uv add` (runtime deps) or `uv add --dev` (dev/tooling deps) so
`uv.lock` stays in sync.

Do not add abstractions merely to look clean.

Do not replace readable code with clever code.

Do not silence warnings without understanding them.

Do not delete Vulture findings blindly.

Do not chase coverage numbers with useless tests.

Do not optimize micro-performance without evidence or clear semantic improvement.

Do not enable every linter rule blindly.

Do not add overlapping tools without a concrete reason.

Do not modify behavior merely to satisfy style tooling.

Prefer:

```text
small
explicit
typed
tested
readable
standard-library-first
easy to debug
easy to remove
easy to verify
```

The goal is not to satisfy tools.

The goal is to leave the Python codebase simpler, safer, more predictable and easier to maintain than it was before.
