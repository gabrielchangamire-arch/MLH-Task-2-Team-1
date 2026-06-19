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

app = Flask(__name__)


@app.route("/")
def index():
    logger.info("Serving index page")
    return render_template(
        "index.html",
        title="MLH Fellow",
        url=os.getenv("URL"),
        team_members=TEAM_MEMBERS,
    )


@app.errorhandler(404)
def page_not_found(error):
    logger.warning("Page not found: %s", error)
    return "Page not found", 404


@app.errorhandler(500)
def internal_server_error(error):
    logger.error("Internal server error: %s", error)
    return "Internal server error", 500
