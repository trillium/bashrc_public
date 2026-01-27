#!/bin/bash
# is-complete.sh
#
# Usage: ./is-complete.sh
#
# Checks if all stories in prd.json are complete.
# Outputs "COMPLETE" if all stories pass, otherwise "INCOMPLETE: N remaining, M blocked"

PRD_FILE="prd.json"

all_complete=$(jq -r '.stories | map(.passes) | all' "$PRD_FILE")

if [ "$all_complete" = "true" ]; then
  echo "COMPLETE"
else
  remaining=$(jq -r '[.stories[] | select(.passes == false and .blocked != true)] | length' "$PRD_FILE")
  blocked=$(jq -r '[.stories[] | select(.blocked == true)] | length' "$PRD_FILE")
  echo "INCOMPLETE: $remaining remaining, $blocked blocked"
fi
