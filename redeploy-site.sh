#!/usr/bin/env bash
set -euo pipefail

# Change these values if the project path, branch, or compose file changes.
PROJECT_DIR="/root/MLH-Task-2-Team-1"
BRANCH="main"
COMPOSE_FILE="docker-compose.prod.yml"
HEALTH_URL="https://gabriel-p.duckdns.org/timeline"
PUBLIC_URL="https://gabriel-p.duckdns.org"

# Run every deploy command from the project folder so paths stay predictable.
echo "Moving into the project directory..."
cd "$PROJECT_DIR"

# Make the VPS checkout match the latest main branch from GitHub exactly.
echo "Pulling the latest code from GitHub..."
git fetch origin "$BRANCH"
git reset --hard "origin/$BRANCH"

# Stop the old containers first so the VPS has enough memory for a clean build.
echo "Stopping existing containers..."
docker compose -f "$COMPOSE_FILE" down

# Rebuild the Flask image and start the app/database containers in the background.
echo "Building and starting Docker containers..."
docker compose -f "$COMPOSE_FILE" up -d --build

# NGINX may need time to refresh certificates before HTTPS is ready.
echo "Checking the HTTPS site..."
for attempt in {1..60}; do
  if curl --fail --silent --show-error --max-time 10 "$HEALTH_URL" >/dev/null; then
    echo "Redeploy complete."
    echo "Live URL: $PUBLIC_URL"
    echo "Logs: docker compose -f $COMPOSE_FILE logs -f"
    exit 0
  fi

  echo "Waiting for HTTPS to respond... ($attempt/60)"
  sleep 5
done

echo "The HTTPS site did not respond at $HEALTH_URL."
echo "Check containers with: docker compose -f $COMPOSE_FILE ps"
echo "Check logs with: docker compose -f $COMPOSE_FILE logs --tail=80"
exit 1
