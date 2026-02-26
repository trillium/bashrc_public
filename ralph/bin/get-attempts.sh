#!/bin/bash
# get-attempts.sh
#
# Usage: ./get-attempts.sh <story-id>
#
# Retrieves the list of previous attempt file paths from the attempts array
# for the specified story ID from prd.json.
#
# Example: ./get-attempts.sh story-18

if [ -z "$1" ]; then
  echo "Usage: $0 <story-id>"
  exit 1
fi

# Get the attempts array for the specified story
ATTEMPTS=$(jq -r --arg id "$1" '.stories[] | select(.id == $id) | .attempts[]?' prd.json 2>/dev/null)

# Check if any attempts were found
if [ -z "$ATTEMPTS" ]; then
  # Return empty output silently (for easy script consumption)
  exit 0
fi

# Output one file path per line
echo "$ATTEMPTS"
