# docker-camunda-konga-letsencrypt — Claude Instructions

## Purpose

Docker Compose infrastructure for:
- **Camunda BPM** — official workflow engine (some flows migrating to n8n)
- **Kong API Gateway** — routes all API traffic for Mevio services
- **Konga** — Kong admin GUI
- **nginx-proxy + acme-companion** — automatic SSL via Let's Encrypt

## Stack

| Service | Version | Domain |
|---|---|---|
| Kong | 2.3.2-alpine | api.over9k.com.br (port 8000) |
| Konga | latest | konga.over9k.com.br (port 1337) |
| Camunda BPM | custom | camunda.over9k.com.br (port 8080) |
| PostgreSQL | 9.5 | DigitalOcean managed DB |
| nginx-proxy | latest | (SSL termination) |
| acme-companion | latest | (Let's Encrypt certs) |

## Compose Files

```
docker-compose-camunda-konga.yml   — Kong + Konga + Camunda + PostgreSQL
docker-compose-letsencrypt.yml     — nginx-proxy + acme-companion (SSL)
Dockerfile                         — Custom Camunda BPM with PostgreSQL config
camunda-config/
  bpm-platform.xml                 — Camunda DB and engine config
  logging.properties               — Log levels
```

## Docker Networks

All services share the `letsencrypt` external Docker network. This network must be created before starting:

```bash
docker network create letsencrypt
```

The `pandoc-api` service also attaches to this same network for SSL.

## Starting Services

```bash
# SSL proxy (start first):
docker-compose -f docker-compose-letsencrypt.yml up -d

# Application services:
docker-compose -f docker-compose-camunda-konga.yml up -d
```

## Key Rules

- **This setup affects production routing and SSL.** Confirm with the user before applying infrastructure changes.
- Kong routes must be updated when new Mevio API endpoints are exposed publicly.
- Camunda is the official workflow engine; new BPMN workflows can still go here, but some are migrating to n8n.
- PostgreSQL is managed externally (DigitalOcean) — do not try to run it locally in Docker for production data.
- SSL certificates are auto-renewed by acme-companion; do not manually modify cert files.
- Konga admin interface should not be publicly accessible without authentication — verify Kong admin API is not exposed.

## Environment Variables Needed

```
# PostgreSQL (DigitalOcean managed):
POSTGRES_HOST, POSTGRES_PORT, POSTGRES_DB, POSTGRES_USER, POSTGRES_PASSWORD

# Let's Encrypt:
DEFAULT_EMAIL   — email for cert registration

# Kong:
KONG_DATABASE=postgres
```
