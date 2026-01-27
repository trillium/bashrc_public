#!/bin/bash
# record-failure.sh
#
# Usage: ./record-failure.sh <story-id> <context-file>
#
# Records a failed attempt for the specified story by adding the context file to the attempts array.

if [ $# -lt 2 ]; then
  echo "Usage: $0 <story-id> <context-file>"
  exit 1
fi

story_id="$1"
context_file="$2"
PRD_FILE="prd.json"

jq --arg sid "$story_id" --arg file "$context_file" '
  (.stories[] | select(.id == $sid) | .attempts) |=
  (if . == null then [$file] else . + [$file] end)
' "$PRD_FILE" > "$PRD_FILE.tmp" && mv "$PRD_FILE.tmp" "$PRD_FILE"

echo "✅ Recorded failure: $context_file"
