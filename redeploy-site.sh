#!/usr/bin/env bash
set -euo pipefail

# Change these values if the project path, branch, or compose file changes.
PROJECT_DIR="/root/MLH-Task-2-Team-1"
BRANCH="main"
COMPOSE_FILE="docker-compose.prod.yml"
LOCAL_URL="http://127.0.0.1:5000/"
PUBLIC_URL="http://gabriel-p.duckdns.org:5000"

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

# Give Flask a few seconds to boot before checking the local URL.
echo "Checking the local site..."
for attempt in {1..10}; do
  if curl --fail --silent --show-error --max-time 3 "$LOCAL_URL" >/dev/null; then
    echo "Redeploy complete."
    echo "Live URL: $PUBLIC_URL"
    echo "Logs: docker compose -f $COMPOSE_FILE logs -f"
    exit 0
  fi

  echo "Waiting for Flask to start... ($attempt/10)"
  sleep 1
done

echo "Flask did not respond at $LOCAL_URL."
echo "Check containers with: docker compose -f $COMPOSE_FILE ps"
echo "Check logs with: docker compose -f $COMPOSE_FILE logs --tail=80"
exit 1
