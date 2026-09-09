# OpenWebUI Deployment with Kamal

This repository contains the configuration for deploying OpenWebUI on a VPS using Kamal (container orchestration) and PostgreSQL.

## Prerequisites

- VPS with Docker installed
- PostgreSQL already installed on the VPS
- Kamal installed locally
- GitHub Container Registry (GHCR) or Docker Hub access

## Quick Start

1. Configure your VPS details in `config/deploy.yml`
2. Set up environment variables
3. Deploy with Kamal

## Configuration Files

- `config/deploy.yml` - Kamal deployment configuration
- `.env.example` - Environment variables template
- `docker-compose.yml` - Local development configuration
- `Dockerfile` - OpenWebUI Docker image configuration

## Deployment Steps

See DEPLOYMENT.md for detailed setup instructions.
