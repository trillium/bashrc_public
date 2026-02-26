#!/bin/bash
# Git wrapper to prevent accidental 'git add .' commands
# Enforces explicit file additions for better version control practices

git() {
  if [[ "$1" == "add" && ("$2" == "." || "$2" == "-A" || "$2" == "--all") ]]; then
    for arg in "$@"; do
      if [[ "$arg" == "--force" ]]; then
        command git "$@"
        return $?
      fi
    done
    echo "❌ Error: Not allowed. Add files explicitly."
    return 1
  fi
  command git "$@"
}
