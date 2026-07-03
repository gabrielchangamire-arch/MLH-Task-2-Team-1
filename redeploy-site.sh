#!/usr/bin/env bash
set -euo pipefail

# Change these values if the project path, branch, or tmux session name changes.
PROJECT_DIR="/root/MLH-Task-2-Team-1"
VENV_DIR="$PROJECT_DIR/python3-virtualenv"
SESSION_NAME="portfolio"
BRANCH="main"
LOCAL_URL="http://127.0.0.1:5000/"
PUBLIC_URL="http://gabriel-p.duckdns.org:5000"

# The assignment asks us to stop all tmux sessions first. That clears out any
# old Flask server that might still be serving an older version of the site.
echo "Stopping existing tmux sessions..."
tmux kill-server 2>/dev/null || true

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

# Start Flask in a detached tmux session so it stays up after SSH disconnects.
echo "Starting Flask in tmux session: $SESSION_NAME"
tmux new-session -d -s "$SESSION_NAME" \
  "cd '$PROJECT_DIR' && source '$VENV_DIR/bin/activate' && export FLASK_ENV=development FLASK_APP=app && flask run --host=0.0.0.0"

# Give Flask a few seconds to boot before checking the local URL.
echo "Checking the local site..."
for attempt in {1..10}; do
  if curl --fail --silent --show-error --max-time 3 "$LOCAL_URL" >/dev/null; then
    echo "Redeploy complete."
    echo "Live URL: $PUBLIC_URL"
    echo "Logs: tmux attach -t $SESSION_NAME"
    exit 0
  fi

  echo "Waiting for Flask to start... ($attempt/10)"
  sleep 1
done

echo "Flask did not respond at $LOCAL_URL."
echo "Check logs with: tmux attach -t $SESSION_NAME"
exit 1
