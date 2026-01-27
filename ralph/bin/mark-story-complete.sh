#!/bin/bash
# mark-story-complete.sh
#
# Usage: ./mark-story-complete.sh <story-id>
#
# Marks the specified story as complete (passes=true) in prd.json.

if [ -z "$1" ]; then
  echo "Usage: $0 <story-id>"
  exit 1
fi

jq '(.stories[] | select(.id == "'$1'") | .passes) = true' prd.json > prd.tmp.json && mv prd.tmp.json prd.json
