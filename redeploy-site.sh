#!/usr/bin/env bash
set -euo pipefail

# Change these values if the project path, branch, or service name changes.
PROJECT_DIR="/root/MLH-Task-2-Team-1"
VENV_DIR="$PROJECT_DIR/python3-virtualenv"
BRANCH="main"
SERVICE_NAME="myportfolio"
LOCAL_URL="http://127.0.0.1:5000/"
PUBLIC_URL="http://gabriel-p.duckdns.org:5000"

# Run every deploy command from the project folder so paths stay predictable.
echo "Moving into the project directory..."
cd "$PROJECT_DIR"

# Make the VPS checkout match the latest main branch from GitHub exactly.
echo "Pulling the latest code from GitHub..."
git fetch origin "$BRANCH"
git reset --hard "origin/$BRANCH"

# Refresh dependencies inside the existing virtual environment.
echo "Installing Python dependencies..."
source "$VENV_DIR/bin/activate"
python -m pip install -r requirements.txt

# systemd owns the Flask process now, so a restart is cleaner than tmux.
echo "Restarting $SERVICE_NAME service..."
systemctl restart "$SERVICE_NAME"

# Give Flask a few seconds to boot before checking the local URL.
echo "Checking the local site..."
for attempt in {1..10}; do
  if curl --fail --silent --show-error --max-time 3 "$LOCAL_URL" >/dev/null; then
    echo "Redeploy complete."
    echo "Live URL: $PUBLIC_URL"
    echo "Logs: journalctl -u $SERVICE_NAME -f"
    exit 0
  fi

  echo "Waiting for Flask to start... ($attempt/10)"
  sleep 1
done

echo "Flask did not respond at $LOCAL_URL."
echo "Check service status with: systemctl status $SERVICE_NAME"
echo "Check logs with: journalctl -u $SERVICE_NAME -n 50"
exit 1
