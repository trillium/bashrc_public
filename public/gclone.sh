#!/usr/bin/env zsh
# gclone - Clone git repositories to the cdcode directory
# Version: 1.1.0

gclone() {
# Get the cdcode directory (defaults to ~/code)
# This handles both alias and function definitions
local CODE_DIR
if type cdcode &>/dev/null; then
    # Extract directory from cdcode alias/function
    CODE_DIR=$(alias cdcode 2>/dev/null | sed -n "s/.*cd \([^']*\).*/\1/p")
    if [[ -z "$CODE_DIR" ]]; then
        # If not an alias, try to evaluate it
        CODE_DIR="$HOME/code"
    fi
    # Expand ~ to actual home directory
    CODE_DIR="${CODE_DIR/#\~/$HOME}"
else
    CODE_DIR="$HOME/code"
fi

# Usage function
usage() {
    cat << EOF
Usage: gclone [--dir <subdir>] <git-url> [directory-name]

Clone a git repository to the cdcode directory ($CODE_DIR)

Arguments:
  git-url         Git repository URL (https:// or git@)
  directory-name  Optional: Custom directory name (defaults to repo name)

Options:
  --dir <subdir>  Clone into a subdirectory within the code directory
                  The subdirectory will be created if it doesn't exist
                  Result: $CODE_DIR/<subdir>/<repo-name>

Examples:
  gclone https://github.com/user/repo.git
  gclone git@github.com:user/repo.git
  gclone https://github.com/user/repo.git my-custom-name
  gclone --dir projects https://github.com/user/repo.git
  gclone --dir work/clients https://github.com/user/repo.git custom-name

The repository will be cloned to: $CODE_DIR/<directory-name>
With --dir: $CODE_DIR/<subdir>/<directory-name>
EOF
}

# Check for help flag
if [[ "$1" == "-h" || "$1" == "--help" || -z "$1" ]]; then
    usage
    return 0
fi

# Parse arguments
local SUBDIR=""
local GIT_URL=""
local CUSTOM_NAME=""

# Check for --dir flag
if [[ "$1" == "--dir" ]]; then
    if [[ -z "$2" ]]; then
        echo "Error: --dir requires a subdirectory argument"
        echo ""
        usage
        return 1
    fi
    SUBDIR="$2"
    shift 2
fi

# Get git URL and optional custom name
GIT_URL="$1"
CUSTOM_NAME="$2"

# Validate git URL
if [[ ! "$GIT_URL" =~ ^(https?://|git@) ]]; then
    echo "Error: Invalid git URL format. Must start with https://, http://, or git@"
    echo ""
    usage
    return 1
fi

# Determine the target directory
local TARGET_DIR="$CODE_DIR"
if [[ -n "$SUBDIR" ]]; then
    TARGET_DIR="$CODE_DIR/$SUBDIR"
fi

# Create target directory if it doesn't exist
if [[ ! -d "$TARGET_DIR" ]]; then
    echo "Creating directory: $TARGET_DIR"
    mkdir -p "$TARGET_DIR" || {
        echo "Error: Failed to create directory $TARGET_DIR"
        return 1
    }
fi

# Clone the repository
echo "Cloning to: $TARGET_DIR"
if [[ -n "$CUSTOM_NAME" ]]; then
    git clone "$GIT_URL" "$TARGET_DIR/$CUSTOM_NAME"
else
    git -C "$TARGET_DIR" clone "$GIT_URL"
fi

# Check if clone was successful
if [[ $? -eq 0 ]]; then
    # Get the cloned directory name
    local REPO_NAME
    if [[ -n "$CUSTOM_NAME" ]]; then
        REPO_NAME="$CUSTOM_NAME"
    else
        REPO_NAME=$(basename "$GIT_URL" .git)
    fi

    echo ""
    echo "Successfully cloned to: $TARGET_DIR/$REPO_NAME"
    echo "To navigate there, run: cd $TARGET_DIR/$REPO_NAME"
else
    echo ""
    echo "Error: Git clone failed"
    return 1
fi
}
