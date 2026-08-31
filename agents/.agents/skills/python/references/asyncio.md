# asyncio

- Async is for concurrent I/O or existing async architecture, not style.
- Use `TaskGroup` for related child tasks; define ownership and cancellation.
- Bound concurrency with semaphores/queues; avoid unbounded `gather`.
- Use explicit timeouts at network/process boundaries.
- Never swallow `CancelledError`; clean up then re-raise.
- Move unavoidable blocking work off event loop.
- Close clients, streams, subprocesses, tasks, and background workers deterministically.
- Test cancellation, timeout, partial failure, and resource cleanup.
