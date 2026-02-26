BASHPROFILE_DIR=${BASHPROFILE_DIR}

function edit() {
    # Always open the workspace root in VS Code
    BASHPROFILE_DIR="/Users/trilliumsmith/bashrc_dir"
    echo "Opening workspace at $BASHPROFILE_DIR"
    code "$BASHPROFILE_DIR"
}