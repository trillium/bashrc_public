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
  cat <<'EOF'
Usage: ralph.sh <command> [args]

Commands:
  find-next
      Find the next available story to work on.
      Returns: "priority id title" of next story, or empty if none available.

  get-details <story-id>
      Get details for the specified story ID from prd.json.
      Example: ralph.sh get-details story-18

  mark-complete <story-id>
      Mark the specified story as complete (sets passes=true in prd.json).
      Example: ralph.sh mark-complete story-18

  record-failure <story-id> <context-file>
      Record a failed attempt by adding context-file to story's attempts array.
      Example: ralph.sh record-failure story-18 progress/story-18_context.md

  block-story <story-id>
      Mark a story as blocked (typically after max attempts exceeded).
      Example: ralph.sh block-story story-18

  is-complete
      Check if all stories are complete.
      Returns: "COMPLETE" or "INCOMPLETE: N remaining, M blocked"

  create-progress <json-string>
      Create a progress file (success log or failure context dump).

      For SUCCESS, JSON must contain:
        {
          "storyId": "story-18",
          "status": "success",
          "model": "claude-sonnet-4",
          "summary": "What was implemented",
          "filesChanged": "List of files changed",
          "learnings": "Learnings for future iterations",
          "validationResults": "Test results or validation output"
        }
      Output: Appends entry to progress.txt

      For FAILURE, JSON must contain:
        {
          "storyId": "story-18",
          "status": "failure",
          "model": "claude-sonnet-4",
          "failureReason": "Short description of failure",
          "whatAttempted": "What you tried to implement",
          "errorsEncountered": "Error messages or issues",
          "whatWasTried": "Debugging steps taken",
          "learnings": "What was learned from this attempt",
          "recommendations": "Suggested next steps"
        }
      Output: Creates progress/story-18_TIMESTAMP_issue-slug.md

Environment Variables:
  RALPH_WORK_DIR    Directory containing prd.json (defaults to current directory)

Examples:
  ./ralph.sh find-next
  ./ralph.sh get-details story-18
  ./ralph.sh create-progress '{"storyId":"story-18","status":"success",...}'
EOF
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
    (cd "$WORK_DIR" && "$SCRIPT_DIR/bin/record-failure.sh" "$@")
    ;;
  block-story)
    if [ $# -lt 1 ]; then
      echo "Error: story-id required for block-story."
      show_help
      exit 1
    fi
    (cd "$WORK_DIR" && "$SCRIPT_DIR/bin/block-story.sh" "$@")
    ;;
  is-complete)
    (cd "$WORK_DIR" && "$SCRIPT_DIR/bin/is-complete.sh" "$@")
    ;;
  create-progress)
    if [ $# -lt 1 ]; then
      echo "Error: JSON args required for create-progress."
      show_help
      exit 1
    fi
    (cd "$WORK_DIR" && "$SCRIPT_DIR/bin/create-progress.sh" "$@")
    ;;
  *)
    echo "Unknown command: $COMMAND"
    show_help
    exit 1
    ;;
esac
