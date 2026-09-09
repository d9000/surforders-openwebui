# openwebui

Standalone OpenWebUI deployment for Surforders AI. Independent from the [surforders](https://github.com/d9000/surforders) Rails app — separate repo, Kamal stack, and secrets.

- **Production:** `https://openwebui.surforders.com` (Kamal + `ghcr.io/open-webui/open-webui` image)
- **Database:** PostgreSQL 16 (Kamal accessory)
- **Local dev:** `docker compose up`

## Prerequisites

- VPS with Docker (same host as Surforders/Odoo is fine)
- DNS: `openwebui.surforders.com` → VPS IP
- Docker Hub account (for Kamal image push)
- GitHub Actions secrets (see below)

## Quick start (local)

```bash
cp .env.example .env
docker compose up -d
open http://localhost:8080
```

## Production deploy

Production secrets live in **GitHub** (repository or `production` environment secrets). CI injects them as environment variables; `.kamal/secrets` in the repo is only a passthrough map.

### 1. GitHub Actions secrets

| Secret | Purpose |
|--------|---------|
| `SSH_PRIVATE_KEY` | VPS SSH key |
| `DEPLOY_HOST` | VPS hostname/IP |
| `DEPLOY_USER` | SSH user (e.g. `ubuntu`) |
| `DOCKER_HUB_USER` | Registry username |
| `DOCKER_HUB_TOKEN` | Registry token |
| `POSTGRES_PASSWORD` | Postgres + OpenWebUI DB password |
| `WEBUI_SECRET_KEY` | OpenWebUI secret key for sessions |

`POSTGRES_PASSWORD` is the single source of truth for database credentials.

### 2. Deploy

Push to `main`. CI will:

1. Boot Postgres on the `kamal` Docker network with `POSTGRES_PASSWORD`
2. Deploy OpenWebUI + Kamal proxy
3. Wait for the app to be healthy
4. OpenWebUI initializes its database on first run

Or deploy manually from your machine with a populated `.env`:

```bash
gem install kamal -v 2.3.0
./bin/deploy   # kamal deploy
```

## Connect external apps

Point any client at:

```
OPENWEBUI_URL=https://openwebui.surforders.com
```

## Local Development

```bash
docker compose up -d
# Create database via web UI at http://localhost:8080
# or use docker compose exec
```

## Teardown

```bash
docker compose down -v
```

## Layout

```
Dockerfile              # FROM ghcr.io/open-webui/open-webui + Kamal service label
docker-compose.yml      # local dev
config/deploy.yml       # Kamal production
.env.example            # environment variables template
bin/deploy              # kamal deploy wrapper (optional)
```

## Notes

- Runtime is the **official** OpenWebUI image; Dockerfile can add custom configuration
- Postgres is not exposed publicly — only OpenWebUI goes through kamal-proxy on 443
- Follow the same deployment pattern as the Odoo project for consistency
