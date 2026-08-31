# Boundaries

- Group by cohesive capability/feature, not technical layer alone.
- Dependencies point toward stable domain policy.
- Define input/output contracts at module boundaries.
- Avoid shared modules that become unowned dumping grounds.
- Keep persistence, HTTP, CLI, queue, and vendor SDKs behind adapters.
- Transactions and consistency belong to an explicit owner.
- Cross-boundary calls expose timeout, retry, idempotency, and failure semantics.
