# Migrations

One-time changes that a config link cannot carry: deleting an old file, swapping
a package, moving data. Each `.sh` here runs once per machine, in name order.

```bash
dots migrate new remove-old-thing
dots migrate
```

Write them so they are safe to run again: a failed one runs again next time. A
new machine marks the existing ones as done, because it already starts current.
