"""Copy Flask static assets into public/ for Vercel's CDN."""

import shutil
from pathlib import Path

STATIC_SRC = Path("app/static")
STATIC_DEST = Path("public/static")


def main():
    if STATIC_DEST.exists():
        shutil.rmtree(STATIC_DEST)

    if STATIC_SRC.exists():
        shutil.copytree(STATIC_SRC, STATIC_DEST)
        print(f"Copied {STATIC_SRC} -> {STATIC_DEST}")
    else:
        print(f"No static assets found at {STATIC_SRC}")


if __name__ == "__main__":
    main()
