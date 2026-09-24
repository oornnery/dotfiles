# Python web architecture

Typical dependency direction:

```text
routes -> services -> repositories/session/models
routes -> schemas/forms/templates
services -> domain + repositories
models/domain -> no route/template imports
templates -> no business rules
```

For a new app or a new area, settle these before building:

- route and template map;
- request/form/response contracts;
- transaction boundaries;
- authentication/session and authorization policy;
- public/admin separation;
- migration and rollback;
- deployment/runtime assumptions;
- cache/background work only when required.
