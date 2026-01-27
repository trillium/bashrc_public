#!/bin/bash
# find-next-available-story.sh
#
# Usage: ./find-next-available-story.sh
#
# Finds the next available story to work on from prd.json, considering dependencies and pass status.
#
# Outputs: "priority id title" of the next available story (sorted by priority, takes the top one)

jq -r '
  . as $root |
  .stories[] |
  select(.passes == false) |
  select(.blocked != true) |
  select(
    all(.dependencies[]?; . as $dep |
      any($root.stories[]; .id == $dep and .passes == true)
    ) or (.dependencies | length == 0)
  ) |
  "\(.priority) \(.id) \(.title)"
' prd.json | sort | head -1
