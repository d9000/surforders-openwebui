# OpenWebUI Deployment Guide

This repository now follows the same deployment shape as the Surforders Odoo repo:

- GitHub Actions triggers deployment on `main`
- Kamal 2 builds and pushes the app image to Docker Hub
- The VPS runs OpenWebUI plus a PostgreSQL 16 accessory on the `kamal` Docker network
- Secrets stay in GitHub and are passed through `.kamal/secrets`

## Prerequisites

- VPS with SSH access
- Docker installed on the VPS
- DNS for `openwebui.surforders.com` pointed at the VPS
- Docker Hub credentials
- A GitHub `production` environment or repository secrets

## Required GitHub secrets

- `SSH_PRIVATE_KEY`
- `DEPLOY_HOST`
- `DEPLOY_HOST_KEY`
- `DEPLOY_USER`
- `DOCKER_HUB_USER`
- `DOCKER_HUB_TOKEN`
- `POSTGRES_PASSWORD`
- `WEBUI_SECRET_KEY`

`POSTGRES_PASSWORD` is used both by the PostgreSQL accessory and by OpenWebUI's `DATABASE_PASSWORD`.
`DEPLOY_HOST_KEY` should be the exact `known_hosts` line for the VPS, so CI does not trust a host key fetched at deploy time.

## VPS preparation

Install Docker if it is not already available:

```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker "$USER"
```

No host PostgreSQL install is required. Kamal manages the PostgreSQL accessory container.

## Manual deploy

On your machine:

```bash
cp .env.example .env
gem install kamal -v 2.3.0
./bin/deploy
```

`.env` should define:

- `DEPLOY_HOST`
- `DEPLOY_USER`
- `DOCKER_HUB_USER`
- `DOCKER_HUB_TOKEN`
- `POSTGRES_PASSWORD`
- `WEBUI_SECRET_KEY`

## CI deploy

Push to `main` or run the **Deploy OpenWebUI** workflow manually.

The workflow:

1. Checks out the repo
2. Installs Ruby and Kamal 2.3.0
3. Loads the SSH key
4. Validates the rendered Kamal config
5. Runs `./bin/deploy`

## Verification

After deployment:

```bash
curl -I https://openwebui.surforders.com
kamal logs -f
kamal app details
```

The application health endpoint is:

```text
/api/v1/health
```

## Local development

```bash
cp .env.example .env
docker compose up -d
open http://localhost:8080
```
