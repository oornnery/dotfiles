# System design decision

Capture:

1. context and problem;
2. goals/non-goals;
3. constraints and invariants;
4. current state;
5. proposed boundaries/data flow;
6. API/data model;
7. failure, security, observability;
8. migration/rollout/rollback;
9. alternatives and trade-offs;
10. validation and acceptance criteria.

Prefer incremental migration with compatibility window over flag-day rewrite.
