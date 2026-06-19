import logging
import os

from flask import Flask, render_template
from dotenv import load_dotenv

load_dotenv()

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s %(levelname)s %(name)s: %(message)s",
)
logger = logging.getLogger(__name__)

TEAM_MEMBERS = [
    {"name": "Adam Maatouk", "photo": "adam-maatouk.png"},
    {"name": "Amar Kanakamedala", "photo": "amar-kanakamedala.png"},
    {"name": "Gabriel Changamire", "photo": "gabriel-changamire.png"},
]

# Add new pages here to include them in the navigation bar.
NAV_PAGES = [
    {"endpoint": "index", "label": "Home"},
    {"endpoint": "hobbies", "label": "Hobbies"},
]

# Add hobby entries here when ready: {"name": "...", "image": "..."}
HOBBIES = []

app = Flask(__name__)


@app.context_processor
def inject_globals():
    return {
        "nav_pages": NAV_PAGES,
        "url": os.getenv("URL"),
    }


@app.route("/")
def index():
    logger.info("Serving index page")
    return render_template(
        "index.html",
        title="MLH Fellow",
        team_members=TEAM_MEMBERS,
    )


@app.route("/hobbies")
def hobbies():
    logger.info("Serving hobbies page")
    return render_template("hobbies.html", hobbies=HOBBIES)


@app.errorhandler(404)
def page_not_found(error):
    logger.warning("Page not found: %s", error)
    return "Page not found", 404


@app.errorhandler(500)
def internal_server_error(error):
    logger.error("Internal server error: %s", error)
    return "Internal server error", 500
