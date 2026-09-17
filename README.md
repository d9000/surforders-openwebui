# openwebui

Standalone OpenWebUI deployment for Surforders AI. Independent from the [surforders](https://github.com/d9000/surforders) Rails app — separate repo, Kamal stack, and secrets.

- **Production:** `https://openwebui.surforders.com` (Kamal + Docker Hub image built from this repo's Dockerfile)
- **Deploy automation:** GitHub Actions → Kamal 2 → Docker Hub image push → VPS
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

Production secrets live in **GitHub** (repository or `production` environment secrets). CI injects them as environment variables and `.kamal/secrets` maps them into Kamal's secret handling, matching the Surforders Odoo deploy pattern.

### 1. GitHub Actions secrets

| Secret | Purpose |
|--------|---------|
| `SSH_PRIVATE_KEY` | VPS SSH key |
| `DEPLOY_HOST` | VPS hostname/IP |
| `DEPLOY_HOST_KEY` | SSH known_hosts entry for the VPS |
| `DEPLOY_USER` | SSH user (e.g. `ubuntu`) |
| `DOCKER_HUB_USER` | Registry username |
| `DOCKER_HUB_TOKEN` | Registry token |
| `POSTGRES_PASSWORD` | Postgres + OpenWebUI DB password |
| `WEBUI_SECRET_KEY` | OpenWebUI secret key for sessions |

`POSTGRES_PASSWORD` is the single source of truth for production database credentials.

### 2. Deploy

Push to `main` or run the **Deploy OpenWebUI** workflow manually. CI will:

1. Boot Postgres on the `kamal` Docker network with `POSTGRES_PASSWORD`
2. Deploy OpenWebUI + Kamal proxy
3. Wait for the app to be healthy
4. Let OpenWebUI initialize its database on first run

Or deploy manually from your machine with a populated `.env`:

```bash
cp .env.example .env
gem install kamal -v 2.3.0
eval "$(ssh-agent -s)"
ssh-add /path/to/your/deploy_key
./bin/deploy
```

Your local SSH client must already trust the VPS host key, typically via `~/.ssh/known_hosts`.

## Connect external apps

Point any client at:

```
OPENWEBUI_URL=https://openwebui.surforders.com
```

## Local Development

```bash
cp .env.example .env
docker compose up -d
```

The local stack passes `DATABASE_TYPE`, `DATABASE_HOST`, `DATABASE_PORT`, `DATABASE_USER`, `DATABASE_PASSWORD`, and `DATABASE_NAME` directly to OpenWebUI so the app and Postgres stay in sync.

## Teardown

```bash
docker compose down -v
```

## Layout

```
Dockerfile                    # extends the official OpenWebUI image for deploy/runtime wiring
docker-compose.yml            # local dev
config/deploy.yml             # Kamal production
.kamal/secrets                # passthrough map for Kamal secrets
.github/workflows/deploy.yml  # CI deploy workflow
.env.example                  # environment variables template
bin/deploy                    # kamal deploy wrapper
bin/start-openwebui           # builds DATABASE_URL safely before boot
```

## Notes

- Runtime is the **official** OpenWebUI image; Dockerfile can add custom configuration
- Postgres is not exposed publicly — only OpenWebUI goes through kamal-proxy on 443
- This repo now follows the same deployment shape as the Surforders Odoo project
- Health checks use OpenWebUI's `/health` endpoint
