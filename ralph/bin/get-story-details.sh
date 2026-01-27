#!/bin/bash
# get-story-details.sh
#
# Usage: ./get-story-details.sh <story-id>
#
# Gets the details for the specified story ID from prd.json.
#
# Example: ./get-story-details.sh story-18

if [ -z "$1" ]; then
  echo "Usage: $0 <story-id>"
  exit 1
fi

jq --arg id "$1" '.stories[] | select(.id == $id)' prd.json
