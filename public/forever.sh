#!/bin/bash
# forever - Auto-restart any command in a loop
# If the command exits, it will automatically restart in the same terminal
#
# Usage:
#   forever <command> [args...]
#   forever "command with args"
#
# Examples:
#   forever happy
#   forever npm start
#   forever "python server.py --port 8080"

forever() {
    if [ $# -eq 0 ]; then
        echo "Usage: forever <command> [args...]"
        echo "   or: forever \"command with args\""
        echo ""
        echo "Examples:"
        echo "  forever happy"
        echo "  forever npm start"
        echo "  forever \"python server.py --port 8080\""
        return 1
    fi

    while true; do
        echo "Starting: $@"
        "$@"

        EXIT_CODE=$?
        echo ""
        echo "Command exited with code: $EXIT_CODE"
        echo "Restarting in 2 seconds... (Ctrl+C to stop)"
        sleep 2
    done
}

# Only run if executed directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    forever "$@"
fi
