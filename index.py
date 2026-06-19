# Vercel looks for a top-level `app` in index.py, app.py, etc.
# The Flask instance lives in the app package; re-export it here for deployment.
from app import app
