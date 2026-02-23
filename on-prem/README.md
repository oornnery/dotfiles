# On-Prem Stack

Central guide for running the local stack:
- PostgreSQL (`database`)
- LiteLLM (`litellm`)
- Prometheus + Grafana (`monitoring`)

## Prerequisites
- Docker + Docker Compose installed.
- Ports available: `3000`, `4000`, `9090`.

## 1) Prepare environment files
```bash
cd ~/dotfiles/on-prem/database && cp -n .env-example .env
cd ~/dotfiles/on-prem/litellm && cp -n .env-example .env
cd ~/dotfiles/on-prem/monitoring && cp -n .env-example .env
```

## 2) Start stacks (required order)
```bash
cd ~/dotfiles/on-prem/database && docker compose up -d
cd ~/dotfiles/on-prem/litellm && docker compose up -d
cd ~/dotfiles/on-prem/monitoring && docker compose up -d
```

## 3) Access services
- LiteLLM API: `http://localhost:4000`
- Prometheus: `http://localhost:9090`
- Grafana: `http://localhost:3000`
  - Default login from `monitoring/.env`: `admin` / `admin`

## 4) Quick health checks
```bash
cd ~/dotfiles/on-prem/database && docker compose ps
cd ~/dotfiles/on-prem/litellm && docker compose ps
cd ~/dotfiles/on-prem/monitoring && docker compose ps
```

In Grafana, open dashboard:
- `On-Prem Observability (LiteLLM + PostgreSQL)`

## Restart / Stop
Restart one stack:
```bash
cd ~/dotfiles/on-prem/monitoring && docker compose up -d --force-recreate
```

Stop all:
```bash
cd ~/dotfiles/on-prem/monitoring && docker compose down
cd ~/dotfiles/on-prem/litellm && docker compose down
cd ~/dotfiles/on-prem/database && docker compose down
```

## Troubleshooting
- `litellm` appears down in Grafana:
  - Monitoring uses Blackbox probe against `http://litellm-proxy:4000/health/liveliness`.
  - Check Prometheus targets at `http://localhost:9090/targets`.
- PostgreSQL metrics missing:
  - Validate `DATA_SOURCE_URI`, `DATA_SOURCE_USER`, `DATA_SOURCE_PASS` in `monitoring/.env`.
  - Confirm `database` stack is running first.
- Compose variable errors:
  - Ensure `.env` exists in each stack folder.
