# Monitoring Stack

This folder runs Prometheus + Grafana for metrics and visualization.

## What is here
- `docker-compose.yml`: monitoring services.
- `.env`: required runtime configuration (images, ports, credentials).
- `.env-example`: example env file.
- `prometheus.yml`: scrape configuration.
- `grafana/`: Grafana provisioning and dashboards.

## Requirements
- Docker + Docker Compose installed.
- `on-prem/database` running first (for `database-network`).

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

## Access
- Prometheus UI: `http://localhost:9090`
- Grafana UI: `http://localhost:3000` (default from `.env`: `admin` / `admin`)

## Notes
- Current targets:
  - `blackbox-exporter:9115` (probing `http://litellm-proxy:4000/health/liveliness`)
  - `postgres-exporter:9187`
- Prometheus reads static targets from `prometheus.yml`.
- Service images, ports, Grafana credentials and Postgres exporter credentials are loaded from `.env`.
- Grafana provisions a Prometheus datasource and the dashboard `On-Prem Observability (LiteLLM + PostgreSQL)` automatically.
- Grafana also provisions alert rules:
  - `LiteLLM Down`
  - `PostgreSQL Down`
- Open Grafana Alerting page at `http://localhost:3000/alerting/list` to view rule state.
