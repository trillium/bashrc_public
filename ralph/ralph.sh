#!/bin/bash
# ralph.sh
#
# Usage:
#   ./ralph.sh find-next
#   ./ralph.sh get-details <story-id>
#
# Wrapper for Ralph command-line tools.

set -e

show_help() {
  echo "Usage: $0 <command> [args]"
  echo "Commands:"
  echo "  find-next                 Find the next available story to work on."
  echo "  get-details <story-id>    Get details for the specified story ID."
  echo "  mark-complete <story-id>  Mark the specified story as complete (passes=true)."
  echo "  record-failure <story-id> <context-file>  Record a failed attempt."
  echo "  block-story <story-id>    Mark a story as blocked."
  echo "  is-complete               Check if all stories are complete."
  echo "  create-progress <json>    Create progress file (success or failure)."
}

if [ $# -lt 1 ] || [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
  show_help
  exit 0
fi

COMMAND="$1"
shift

# Get the directory to run commands from (either passed via RALPH_WORK_DIR or current dir)
WORK_DIR="${RALPH_WORK_DIR:-$PWD}"

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

case "$COMMAND" in
  find-next)
    (cd "$WORK_DIR" && "$SCRIPT_DIR/bin/find-next-available-story.sh" "$@")
    ;;
  get-details)
    if [ $# -lt 1 ]; then
      echo "Error: story-id required for get-details."
      show_help
      exit 1
    fi
    (cd "$WORK_DIR" && "$SCRIPT_DIR/bin/get-story-details.sh" "$@")
    ;;
  mark-complete)
    if [ $# -lt 1 ]; then
      echo "Error: story-id required for mark-complete."
      show_help
      exit 1
    fi
    (cd "$WORK_DIR" && "$SCRIPT_DIR/bin/mark-story-complete.sh" "$@")
    ;;
  record-failure)
    if [ $# -lt 2 ]; then
      echo "Error: story-id and context-file required for record-failure."
      show_help
      exit 1
    fi
    story_id="$1"
    context_file="$2"
    cd "$WORK_DIR"
    PRD_FILE="prd.json"
    jq --arg sid "$story_id" --arg file "$context_file" '
      (.stories[] | select(.id == $sid) | .attempts) |= 
      (if . == null then [$file] else . + [$file] end)
    ' "$PRD_FILE" > "$PRD_FILE.tmp" && mv "$PRD_FILE.tmp" "$PRD_FILE"
    echo "✅ Recorded failure: $context_file"
    ;;
  block-story)
    if [ $# -lt 1 ]; then
      echo "Error: story-id required for block-story."
      show_help
      exit 1
    fi
    story_id="$1"
    cd "$WORK_DIR"
    PRD_FILE="prd.json"
    jq --arg sid "$story_id" \
      '(.stories[] | select(.id == $sid) | .blocked) = true' \
      "$PRD_FILE" > "$PRD_FILE.tmp" && mv "$PRD_FILE.tmp" "$PRD_FILE"
    echo "⛔ Blocked story: $story_id (max attempts exceeded)"
    ;;
  is-complete)
    cd "$WORK_DIR"
    PRD_FILE="prd.json"
    all_complete=$(jq -r '.stories | map(.passes) | all' "$PRD_FILE")
    if [ "$all_complete" = "true" ]; then
      echo "COMPLETE"
    else
      remaining=$(jq -r '[.stories[] | select(.passes == false and .blocked != true)] | length' "$PRD_FILE")
      blocked=$(jq -r '[.stories[] | select(.blocked == true)] | length' "$PRD_FILE")
      echo "INCOMPLETE: $remaining remaining, $blocked blocked"
    fi
    ;;
  create-progress)
    if [ $# -lt 1 ]; then
      echo "Error: JSON args required for create-progress."
      show_help
      exit 1
    fi
    cd "$WORK_DIR"
    PRD_FILE="prd.json"
    
    # Args passed as JSON string
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
    ;;
  *)
    echo "Unknown command: $COMMAND"
    show_help
    exit 1
    ;;
esac
