# OpenWebUI Docker configuration
FROM ghcr.io/open-webui/open-webui:latest

# Install any additional dependencies if needed
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD curl -f http://localhost:8080/api/v1/health || exit 1

EXPOSE 8080
