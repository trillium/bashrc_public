#!/bin/bash
# create-progress.sh
#
# Usage: ./create-progress.sh <json-args>
#
# Creates a progress file (success or failure) based on JSON arguments.
#
# JSON args should contain:
#   - storyId: The story ID
#   - status: "success" or "failure"
#   - model: The model used
#   - Additional fields depending on status

if [ $# -lt 1 ]; then
  echo "Usage: $0 <json-args>"
  exit 1
fi

PRD_FILE="prd.json"
args_json="$1"

# Extract fields from JSON
story_id=$(echo "$args_json" | jq -r '.storyId')
status=$(echo "$args_json" | jq -r '.status')
model=$(echo "$args_json" | jq -r '.model')

# Create progress directory if it doesn't exist
mkdir -p progress

# Get current timestamp
timestamp=$(date +"%Y-%m-%d_%H%M%S")

if [ "$status" = "success" ]; then
  # Append to progress.txt (success log)
  summary=$(echo "$args_json" | jq -r '.summary // ""')
  files_changed=$(echo "$args_json" | jq -r '.filesChanged // ""')
  learnings=$(echo "$args_json" | jq -r '.learnings // ""')
  validation=$(echo "$args_json" | jq -r '.validationResults // ""')

  # Get current date for header
  current_date=$(date +"%b %d %Y")

  # Get story details for title
  story_title=$(jq -r --arg sid "$story_id" '.stories[] | select(.id == $sid) | .title' "$PRD_FILE")

  # Append to progress.txt
  cat >> progress.txt <<EOF

## $current_date - $story_id

**Story:** $story_title
**Model:** $model

**What was implemented:**
$summary

**Files changed:**
$files_changed

**Learnings for future iterations:**
$learnings

**Validation:**
$validation

---
EOF

  echo "✅ Added success entry to progress.txt"

else
  # Create failure context dump
  failure_reason=$(echo "$args_json" | jq -r '.failureReason // ""')
  what_attempted=$(echo "$args_json" | jq -r '.whatAttempted // ""')
  errors=$(echo "$args_json" | jq -r '.errorsEncountered // ""')
  what_tried=$(echo "$args_json" | jq -r '.whatWasTried // ""')
  learnings=$(echo "$args_json" | jq -r '.learnings // ""')
  recommendations=$(echo "$args_json" | jq -r '.recommendations // ""')

  # Generate issue slug from failure reason
  issue_slug=$(echo "$failure_reason" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | cut -c1-50)

  # Get attempt number
  attempt_num=$(jq -r --arg sid "$story_id" '(.stories[] | select(.id == $sid) | .attempts | length) // 0' "$PRD_FILE")
  attempt_num=$((attempt_num + 1))

  # Get story title
  story_title=$(jq -r --arg sid "$story_id" '.stories[] | select(.id == $sid) | .title' "$PRD_FILE")

  # Create filename
  filename="progress/${story_id}_${timestamp}_${issue_slug}.md"

  # Create context dump file
  cat > "$filename" <<EOF
# Story Failure Context: $story_id

**Story:** $story_title
**Attempt Date:** $(date +"%Y-%m-%d %H:%M:%S %Z")
**Model Used:** $model
**Failure Reason:** $failure_reason
**Attempt Number:** $attempt_num

---

## What Was Attempted

$what_attempted

---

## Errors Encountered

$errors

---

## What I Tried

$what_tried

---

## Current State

**Working Tree:** CLEAN (all changes reverted)

---

## Learnings / Context for Next Attempt

$learnings

---

## Recommended Next Steps

$recommendations

---
EOF

  echo "$filename"
fi
