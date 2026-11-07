---
description: Add meaningful tests for a behavior using the repository's existing test setup.
argument-hint: [behavior]
---

Add tests for: $ARGUMENTS

- Use the test runner, layout, fixtures and naming already in the repository.
- Test intent and failure mode, not just a shallow return value.
- Mock external boundaries, not the logic under test.
- For a bug, write the test that fails first, then confirm the fix turns it green.
- Never weaken an existing test to make a suite pass.
- Report the real pass/fail counts.
