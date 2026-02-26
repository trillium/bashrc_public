#!/bin/bash

# Kill process running on specified port or by application name
# Usage: KILL 3000 or KILL "Visual Studio Code"
KILL() {
  if [ -z "$1" ]; then
    echo "Usage: KILL <port_number> or KILL <application_name>"
    echo "Examples: KILL 3000 or KILL \"Visual Studio Code\""
    return 1
  fi

  local target=$1

  # Check if target is a port number (all digits)
  if [[ $target =~ ^[0-9]+$ ]]; then
    local port=$target
    local pids=$(lsof -ti:$port)

    if [ -z "$pids" ]; then
      echo "No process found running on port $port"
      return 0
    fi

    echo "Killing process(es) on port $port: $pids"
    lsof -ti:$port | xargs kill -9

    if [ $? -eq 0 ]; then
      echo "Successfully killed process(es) on port $port"
    else
      echo "Failed to kill process(es) on port $port"
      return 1
    fi
  else
    # Treat as application name
    case $target in
      code|vscode)
        echo "Killing Visual Studio Code and Code Helper processes..."
        pkill "Visual Studio Code"
        pkill "Code Helper"
        ;;
      *)
        echo "Killing processes matching: $target"
        pkill "$target"
        ;;
    esac

    if [ $? -eq 0 ]; then
      echo "Successfully killed process(es) matching: $target"
    else
      echo "Failed to kill process(es) matching: $target"
      return 1
    fi
  fi
}
