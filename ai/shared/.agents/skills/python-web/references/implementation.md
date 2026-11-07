# Python web implementation

Start from the parts of the app factory, settings, routes, templates, DB session,
migrations and tests that the change touches. A persistence change ships with its
migration. Transaction and error behavior live in the service; routes and templates
stay thin.

Cover the states the change can produce, then run the migration, focused route/service
tests, Ruff and ty, plus a browser smoke when the UI changed.

Use `Annotated` dependencies consistently. Avoid creating a session/client per helper
when request/application lifetime already owns it.
