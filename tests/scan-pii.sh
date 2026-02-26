#!/usr/bin/env bash
# scan-pii.sh — Scan shell config files for secrets, tokens, and PII
# Run: ./tests/scan-pii.sh
# Exit code: 0 = clean, 1 = findings

set -euo pipefail
export LC_ALL=C

BASHRC_DIR="$HOME/bashrc_dir"
found=0

# Colors (if terminal supports them)
if [[ -t 1 ]]; then
  RED='\033[0;31m'
  YELLOW='\033[0;33m'
  GREEN='\033[0;32m'
  NC='\033[0m'
else
  RED='' YELLOW='' GREEN='' NC=''
fi

# Files to scan
files=(
  "$HOME/.zshrc"
  "$HOME/.zshenv"
  "$HOME/.zprofile"
  "$BASHRC_DIR/.zshrc"
)
while IFS= read -r -d '' f; do
  files+=("$f")
done < <(find "$BASHRC_DIR/public" "$BASHRC_DIR/private" -type f \( -name '*.sh' -o -name '*.zsh' \) -print0 2>/dev/null)

scan() {
  local label="$1"
  local pattern="$2"
  local severity="${3:-HIGH}"
  local hits

  hits=$(grep -Hrn -E "$pattern" "${files[@]}" 2>/dev/null \
    | grep -v '^\s*#.*scan-pii' \
    | grep -v 'grep -' \
    | grep -v 'PATTERN=' \
    || true)

  if [[ -n "$hits" ]]; then
    if [[ "$severity" == "HIGH" ]]; then
      printf "${RED}[HIGH]${NC} %s\n" "$label"
    else
      printf "${YELLOW}[WARN]${NC} %s\n" "$label"
    fi
    while IFS= read -r line; do
      printf "       %s\n" "$line"
    done <<< "$hits"
    echo ""
    found=1
  fi
}

echo "=== PII & Secrets Scan ==="
echo "    Date: $(date '+%Y-%m-%d')"
echo "    Files scanned: ${#files[@]}"
echo ""

# --- HIGH severity: Likely secrets ---

# API keys with known prefixes (OpenAI, GitHub, GitLab, Slack, AWS, PostHog, Anthropic, Stripe)
scan "API key with known prefix" \
  '\b(sk-[a-zA-Z0-9]{20,}|ghp_[a-zA-Z0-9]{36}|ghu_[a-zA-Z0-9]{36}|glpat-[a-zA-Z0-9]{20}|xox[bprs]-[a-zA-Z0-9-]{20,}|AKIA[0-9A-Z]{16}|phx_[a-zA-Z0-9]{20,}|sk-ant-[a-zA-Z0-9-]{20,}|sk_live_[a-zA-Z0-9]{20,})' \
  HIGH

# Generic secret assignment patterns (KEY=value, TOKEN=value, SECRET=value, PASSWORD=value)
scan "Hardcoded secret assignment" \
  '(API_KEY|AUTH_TOKEN|SECRET_KEY|PASSWORD|PRIVATE_KEY|ACCESS_TOKEN|CLIENT_SECRET)=["\x27]?[a-zA-Z0-9_/+=-]{8,}' \
  HIGH

# Bearer tokens
scan "Bearer token" \
  'Bearer [a-zA-Z0-9_/+=-]{20,}' \
  HIGH

# Base64-encoded blobs that look like credentials (long base64 after = or :)
scan "Possible encoded credential" \
  '(token|secret|key|password|credential|auth)["\x27: =]+[A-Za-z0-9+/]{40,}={0,2}' \
  HIGH

# --- WARN severity: Worth reviewing ---

# Email addresses
scan "Email address" \
  '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' \
  WARN

# IP addresses (not localhost/loopback)
scan "IP address (non-loopback)" \
  '\b(?!127\.|0\.0\.|10\.|172\.(1[6-9]|2[0-9]|3[01])\.|192\.168\.)[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\b' \
  WARN

# SSH private key markers
scan "SSH/PGP private key" \
  '(BEGIN (RSA |DSA |EC |OPENSSH )?PRIVATE KEY|BEGIN PGP PRIVATE)' \
  HIGH

# URLs with embedded credentials (user:pass@host)
scan "URL with embedded credentials" \
  '://[a-zA-Z0-9_]+:[a-zA-Z0-9_]+@' \
  HIGH

# AWS-style secret keys (40 char base64)
scan "Possible AWS secret key" \
  '(aws_secret|AWS_SECRET)[a-zA-Z_]*[=: ]+["\x27]?[A-Za-z0-9/+=]{40}' \
  HIGH

# --- Summary ---
echo "---"
if [[ "$found" -eq 0 ]]; then
  printf "${GREEN}Clean — no PII or secrets detected.${NC}\n"
  exit 0
else
  printf "${RED}Findings above should be reviewed.${NC}\n"
  exit 1
fi
