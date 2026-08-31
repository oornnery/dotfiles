# pytest strategy

- Name test by observable behavior and condition.
- Use fixtures for stable setup, not hidden control flow.
- Parameterize meaningful cases; avoid giant matrices with unclear failures.
- Mock network, clock, filesystem, process, and external service boundaries only.
- Prefer real domain objects and in-memory adapters.
- For bugs, first create smallest test that demonstrates failure.
- For async, verify cancellation/cleanup and avoid arbitrary sleeps.
- Use property testing when invariant spans many inputs.
- Coverage is a signal; assertions and mutation resistance matter more than percentage.
