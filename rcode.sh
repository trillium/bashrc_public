#!/bin/bash

# Script to pipe queries to opencode run in the background
# Usage: ./rcode "your query here"
# Or: echo "your query" | ./rcode

# Function to create filename from query
create_filename() {
    local query="$1"
    # Extract first 10 words, convert to lowercase, replace spaces/special chars with underscores
    local words=$(echo "$query" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9 ]//g' | cut -d' ' -f1-10 | tr ' ' '_')
    # Limit to 50 characters to keep filenames reasonable
    local truncated=$(echo "$words" | cut -c1-50)
    echo "rcode_$(date +%Y%m%d_%H%M%S)_${truncated}.md"
}

# Function to show help
show_help() {
    echo "Usage: $0 [-sync] \"your query here\""
    echo "Or: echo \"your query\" | $0"
    echo ""
    echo "Options:"
    echo "  -sync    Run synchronously (wait for completion)"
    echo ""
    echo "This script runs the query with opencode and saves the output to a timestamped Markdown file."
    echo "The file includes metadata in YAML frontmatter for tracking."
}

# Check for --help or no args
if [[ "$1" == "--help" || "$1" == "-h" || $# -eq 0 ]]; then
    show_help
    exit 0
fi

# Check for -sync flag
SYNC=false
if [[ "$1" == "-sync" ]]; then
    SYNC=true
    shift
fi

# Check if we have command line arguments
if [[ $# -gt 0 ]]; then
    # Use command line arguments as the query
    QUERY="$*"
    OUTPUT_FILE=$(create_filename "$QUERY")
    echo "Output: $OUTPUT_FILE"
    # Write metadata to file
    {
        echo "---"
        echo "query: $QUERY"
        echo "started: $(date)"
        echo "pid: TBD"
        echo "status: running"
        echo "---"
        echo ""
    } > "$OUTPUT_FILE"
    if $SYNC; then
        bash -c "echo \"$QUERY\" | opencode run 2>&1 | sed 's/\x1B\[[0-9;]*[mG]//g' >> \"$OUTPUT_FILE\" && sed -i '' 's/status: running/status: completed/' \"$OUTPUT_FILE\" || sed -i '' 's/status: running/status: failed/' \"$OUTPUT_FILE\""
    else
        nohup bash -c "echo \"$QUERY\" | opencode run 2>&1 | sed 's/\x1B\[[0-9;]*[mG]//g' >> \"$OUTPUT_FILE\" && sed -i '' 's/status: running/status: completed/' \"$OUTPUT_FILE\" || sed -i '' 's/status: running/status: failed/' \"$OUTPUT_FILE\"" 2>/dev/null &
        # Get the background process ID
        BG_PID=$!
        # Update PID in the file
        sed -i '' "s/pid: TBD/pid: $BG_PID/" "$OUTPUT_FILE"
    fi
else
    # Read from stdin - need to capture it first to extract filename
    QUERY=$(cat)
    OUTPUT_FILE=$(create_filename "$QUERY")
    echo "Output: $OUTPUT_FILE"
    # Write metadata to file
    {
        echo "---"
        echo "query: $QUERY"
        echo "started: $(date)"
        echo "pid: TBD"
        echo "status: running"
        echo "---"
        echo ""
    } > "$OUTPUT_FILE"
    if $SYNC; then
        sed -i '' 's/pid: TBD/pid: sync/' "$OUTPUT_FILE"
        bash -c "echo \"$QUERY\" | opencode run 2>&1 | sed 's/\x1B\[[0-9;]*[mG]//g' >> \"$OUTPUT_FILE\" && sed -i '' 's/status: running/status: completed/' \"$OUTPUT_FILE\" || sed -i '' 's/status: running/status: failed/' \"$OUTPUT_FILE\""
    else
        nohup bash -c "echo \"$QUERY\" | opencode run 2>&1 | sed 's/\x1B\[[0-9;]*[mG]//g' >> \"$OUTPUT_FILE\" && sed -i '' 's/status: running/status: completed/' \"$OUTPUT_FILE\" || sed -i '' 's/status: running/status: failed/' \"$OUTPUT_FILE\"" 2>/dev/null &
        # Get the background process ID
        BG_PID=$!
        # Update PID in the file
        sed -i '' "s/pid: TBD/pid: $BG_PID/" "$OUTPUT_FILE"
    fi
fi