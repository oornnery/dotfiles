# Python web implementation

1. Inspect app factory, settings, routes, templates, DB session, migrations, tests.
2. Define schema/form and domain invariant.
3. Add model/migration when persistence changes.
4. Implement service with explicit transaction/error behavior.
5. Add route and template/partial.
6. Cover validation, empty, error, success, disabled/loading states.
7. Add focused route/service tests.
8. Run migration, focused tests, Ruff, ty, and browser smoke when relevant.

Use `Annotated` dependencies consistently. Avoid creating a session/client per helper
when request/application lifetime already owns it.
