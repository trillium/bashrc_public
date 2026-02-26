#!/bin/bash
# Ralph CLI alias for convoluted zshrc loading
# This makes the ralph command available without modifying PATH

ralph() {
  local ralph_dir="$HOME/bashrc_dir/ralph"
  local ralph_script="$ralph_dir/ralph.sh"

  if [[ ! -f "$ralph_script" ]]; then
    echo "Error: Ralph script not found at $ralph_script"
    return 1
  fi

  # Store the current directory where the user is running the command
  local original_dir="$PWD"

  # Change to ralph directory and execute, passing the original directory
  (cd "$ralph_dir" && RALPH_WORK_DIR="$original_dir" bash "./ralph.sh" "$@")
}
