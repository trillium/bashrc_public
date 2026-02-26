#!/usr/bin/env bash
# Run shell profile tests
# Usage: ./tests/run-zshrc-tests.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if ! command -v bats &>/dev/null; then
  echo "Error: bats is not installed. Install with: brew install bats-core"
  exit 1
fi

bats "$SCRIPT_DIR/zshrc.bats" "$@"
