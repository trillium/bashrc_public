#!/bin/bash
# block-story.sh
#
# Usage: ./block-story.sh <story-id>
#
# Marks the specified story as blocked in prd.json (e.g., after max attempts exceeded).

if [ $# -lt 1 ]; then
  echo "Usage: $0 <story-id>"
  exit 1
fi

story_id="$1"
PRD_FILE="prd.json"

jq --arg sid "$story_id" \
  '(.stories[] | select(.id == $sid) | .blocked) = true' \
  "$PRD_FILE" > "$PRD_FILE.tmp" && mv "$PRD_FILE.tmp" "$PRD_FILE"

echo "⛔ Blocked story: $story_id (max attempts exceeded)"
