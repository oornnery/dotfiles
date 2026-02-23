# Database Stack

This folder runs a shared PostgreSQL instance.

## What is here
- `docker-compose.yml`: PostgreSQL service.
- `.env`: required runtime configuration (image/container names, DB users, passwords).
- `.env-example`: example env file.
- `scripts/bootstrap-litellm.sh`: safe DB/role bootstrap script (idempotent).
- `init/`: init scripts for first container bootstrap.

## Requirements
- Docker + Docker Compose installed.

## Start
Create local env file first:
```bash
cp .env-example .env
```

Then start:
```bash
docker compose up -d
```

## Stop
```bash
docker compose down
```

## Create databases
Run bootstrap to load a list file:
```bash
./scripts/bootstrap-litellm.sh
```

By default, `db-bootstrap` reads `DB_BOOTSTRAP_DATABASES_FILE` (default `/databases`).
Each line in the mounted file must be:
```text
db_name:db_user:db_password
```

If you prefer to run manually in a custom path, set:
```dotenv
DATABASES_FILE=./database/databases.txt
```

You can reference values from `.env`:
```text
litellm:${LITELLM_DB_USER}:${LITELLM_DB_PASSWORD}
```

## Safety behavior
- Creates role only if it does not exist.
- Creates database only if it does not exist.
- Exits on invalid entries.

## Automatic LiteLLM bootstrap
- `docker compose up` now also runs `db-bootstrap`, which processes every line in `databases`.
- For each `db_name:db_user:db_password`, it ensures:
	- role exists (or password is updated if it already exists)
	- database exists and is owned by that role
- This removes dependency on manual creation for application databases.
