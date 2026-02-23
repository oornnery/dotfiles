# LiteLLM Stack

This folder runs the LiteLLM proxy service.

## What is here
- `docker-compose.yml`: LiteLLM service definition.
- `.env`: required runtime configuration (image/container/port and app variables).
- `.env-example`: example env file.
- `litellm-config.yaml`: LiteLLM configuration.

## Requirements
- Docker + Docker Compose installed.
- The `database` stack must be running first.
- The `monitoring` stack is optional, but recommended.
- External Docker networks must exist:
  - `database-network`
  - `monitoring-network`

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

## Notes
- LiteLLM reads DB connection from:
  - `LITELLM_DB_USER`
  - `LITELLM_DB_PASSWORD`
  - `LITELLM_DB_NAME`
  - `DB_HOST`
  - `DB_PORT`
- Published LiteLLM port is configured by `LITELLM_PORT` in `.env` (container port remains `4000`).
