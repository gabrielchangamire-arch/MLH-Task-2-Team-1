#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${BASE_URL:-http://127.0.0.1:5000}"
API_URL="$BASE_URL/api/timeline_post"

name="Gabriel Test"
email="gabriel.test.$(date +%s)@example.com"
content="curl-test post $(date +%s)"

echo "Creating a timeline post..."
post_response="$(
  curl --fail --silent --show-error \
    --request POST "$API_URL" \
    --data "name=$name" \
    --data "email=$email" \
    --data "content=$content"
)"

post_id="$(
  POST_RESPONSE="$post_response" python3 - <<'PY'
import json
import os

print(json.loads(os.environ["POST_RESPONSE"])["id"])
PY
)"

echo "Created post id: $post_id"

echo "Checking that the post appears in the GET endpoint..."
get_response="$(curl --fail --silent --show-error "$API_URL")"

GET_RESPONSE="$get_response" EXPECTED_CONTENT="$content" python3 - <<'PY'
import json
import os
import sys

posts = json.loads(os.environ["GET_RESPONSE"])["timeline_posts"]
expected = os.environ["EXPECTED_CONTENT"]

if not any(post["content"] == expected for post in posts):
    print("Could not find the test timeline post in GET response.", file=sys.stderr)
    sys.exit(1)
PY

echo "GET endpoint returned the new post."

echo "Cleaning up the test post..."
curl --fail --silent --show-error \
  --request DELETE "$API_URL/$post_id" >/dev/null

echo "curl timeline endpoint test passed."
