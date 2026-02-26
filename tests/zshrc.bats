#!/usr/bin/env bats

# Shell Profile Test Suite
# Validates that .zshrc and all sourced files are correct and functional.
#
# Run: bats ~/bashrc_dir/tests/zshrc.bats

BASHRC_DIR="$HOME/bashrc_dir"

# Helper: run a command inside a full zsh interactive login shell and capture clean output.
# -i (interactive) ensures .zshrc is sourced; -l (login) ensures .zprofile runs first.
# Uses env vars to pass the command and output path, avoiding bash variable expansion.
zsh_env() {
  local tmpfile
  tmpfile="$(mktemp)"
  _BATS_CMD="$1" _BATS_OUT="$tmpfile" \
    zsh -il -c 'eval "$_BATS_CMD" > "$_BATS_OUT" 2>/dev/null' &>/dev/null
  cat "$tmpfile"
  rm -f "$tmpfile"
}

# Helper: check exit code of a command in zsh interactive login shell (ignores stdout noise)
zsh_env_ok() {
  _BATS_CMD="$1" \
    zsh -il -c 'eval "$_BATS_CMD"' &>/dev/null
}

# =============================================================================
# Static tests — source files must exist on disk
# =============================================================================

@test "source file exists: private/path.sh" {
  [ -f "$BASHRC_DIR/private/path.sh" ]
}

@test "source file exists: private/codewars.sh" {
  [ -f "$BASHRC_DIR/private/codewars.sh" ]
}

@test "source file exists: public/alias_general.sh" {
  [ -f "$BASHRC_DIR/public/alias_general.sh" ]
}

@test "source file exists: public/alias_git.sh" {
  [ -f "$BASHRC_DIR/public/alias_git.sh" ]
}

@test "source file exists: public/caddy_add.sh" {
  [ -f "$BASHRC_DIR/public/caddy_add.sh" ]
}

@test "source file exists: public/cd.sh" {
  [ -f "$BASHRC_DIR/public/cd.sh" ]
}

@test "source file exists: public/edit.sh" {
  [ -f "$BASHRC_DIR/public/edit.sh" ]
}

@test "source file exists: public/find_and_replace.sh" {
  [ -f "$BASHRC_DIR/public/find_and_replace.sh" ]
}

@test "source file exists: public/forever.sh" {
  [ -f "$BASHRC_DIR/public/forever.sh" ]
}

@test "source file exists: public/gclone.sh" {
  [ -f "$BASHRC_DIR/public/gclone.sh" ]
}

@test "source file exists: public/git_wrapper.sh" {
  [ -f "$BASHRC_DIR/public/git_wrapper.sh" ]
}

@test "source file exists: public/kill_port.sh" {
  [ -f "$BASHRC_DIR/public/kill_port.sh" ]
}

@test "source file exists: public/note.sh" {
  [ -f "$BASHRC_DIR/public/note.sh" ]
}

@test "source file exists: public/num_to_word.sh" {
  [ -f "$BASHRC_DIR/public/num_to_word.sh" ]
}

@test "source file exists: public/ralph.sh" {
  [ -f "$BASHRC_DIR/public/ralph.sh" ]
}

@test "source file exists: public/talon_mimic.sh" {
  [ -f "$BASHRC_DIR/public/talon_mimic.sh" ]
}

@test "source file exists: public/terminal.sh" {
  [ -f "$BASHRC_DIR/public/terminal.sh" ]
}

@test "source file exists: public/penguin/penguin.sh" {
  [ -f "$BASHRC_DIR/public/penguin/penguin.sh" ]
}

@test "source file exists: .zshrc (managed config)" {
  [ -f "$BASHRC_DIR/.zshrc" ]
}

@test "source file exists: ~/.zshrc (home wrapper)" {
  [ -f "$HOME/.zshrc" ]
}

@test "source file exists: ~/.antigenrc" {
  [ -f "$HOME/.antigenrc" ]
}

@test "source file exists: chruby.sh" {
  [ -f "/opt/homebrew/opt/chruby/share/chruby/chruby.sh" ]
}

@test "source file exists: chruby auto.sh" {
  [ -f "/opt/homebrew/opt/chruby/share/chruby/auto.sh" ]
}

@test "source file exists: antigen.zsh" {
  [ -f "/opt/homebrew/share/antigen/antigen.zsh" ]
}

# =============================================================================
# Static — .zshrc passes shellcheck
# =============================================================================

@test "shellcheck: bashrc_dir/.zshrc passes" {
  run shellcheck -s bash "$BASHRC_DIR/.zshrc"
  [ "$status" -eq 0 ]
}

@test "shellcheck: ~/.zshrc passes" {
  run shellcheck -s bash "$HOME/.zshrc"
  [ "$status" -eq 0 ]
}

# =============================================================================
# Live environment — environment variables
# =============================================================================

@test "env: GOBIN is set" {
  result="$(zsh_env 'echo $GOBIN')"
  [ -n "$result" ]
  [[ "$result" == *"go/bin"* ]]
}

@test "env: PYENV_ROOT is set" {
  result="$(zsh_env 'echo $PYENV_ROOT')"
  [[ "$result" == *".pyenv"* ]]
}

@test "env: NVM_DIR is set" {
  result="$(zsh_env 'echo $NVM_DIR')"
  [[ "$result" == *".nvm"* ]]
}

@test "env: PNPM_HOME is set" {
  result="$(zsh_env 'echo $PNPM_HOME')"
  [[ "$result" == *"Library/pnpm"* ]]
}

@test "env: HOMEBREW_AUTO_UPDATE_SECS is set" {
  result="$(zsh_env 'echo $HOMEBREW_AUTO_UPDATE_SECS')"
  [[ "$result" == *"86400"* ]]
}

@test "env: PIPENV_PYTHON is set" {
  result="$(zsh_env 'echo $PIPENV_PYTHON')"
  [[ "$result" == *"pyenv"* ]]
}

@test "env: EDITOR is set" {
  result="$(zsh_env 'echo $EDITOR')"
  [ -n "$result" ]
}

# =============================================================================
# Live environment — PATH contains expected entries
# =============================================================================

@test "PATH contains: go/bin" {
  result="$(zsh_env 'echo $PATH')"
  [[ "$result" == *"go/bin"* ]]
}

@test "PATH contains: /opt/homebrew/bin" {
  result="$(zsh_env 'echo $PATH')"
  [[ "$result" == *"/opt/homebrew/bin"* ]]
}

@test "PATH contains: .pyenv/bin" {
  result="$(zsh_env 'echo $PATH')"
  [[ "$result" == *".pyenv/bin"* ]]
}

@test "PATH contains: .local/bin" {
  result="$(zsh_env 'echo $PATH')"
  [[ "$result" == *".local/bin"* ]]
}

@test "PATH contains: Library/pnpm" {
  result="$(zsh_env 'echo $PATH')"
  [[ "$result" == *"Library/pnpm"* ]]
}

# =============================================================================
# Live environment — commands available
# =============================================================================

@test "command available: brew" {
  zsh_env_ok 'command -v brew'
}

@test "command available: git" {
  zsh_env_ok 'command -v git'
}

@test "command available: node" {
  zsh_env_ok 'command -v node'
}

@test "command available: pyenv" {
  zsh_env_ok 'command -v pyenv'
}

@test "command available: ruby" {
  zsh_env_ok 'command -v ruby'
}

@test "command available: chruby" {
  zsh_env_ok 'type chruby'
}

# =============================================================================
# Live environment — aliases defined
# =============================================================================

@test "alias defined: c" {
  zsh_env_ok 'alias c'
}

@test "alias defined: ga (git add)" {
  zsh_env_ok 'alias ga'
}

@test "alias defined: gs (git status)" {
  zsh_env_ok 'alias gs'
}

@test "alias defined: reload" {
  zsh_env_ok 'alias reload'
}

@test "alias defined: zshrc" {
  zsh_env_ok 'alias zshrc'
}

@test "alias defined: help" {
  zsh_env_ok 'alias help'
}

# =============================================================================
# Live environment — functions defined
# =============================================================================

@test "function defined: load-nvmrc" {
  zsh_env_ok 'type load-nvmrc'
}

@test "function defined: edit" {
  zsh_env_ok 'type edit'
}

@test "function defined: ralph" {
  zsh_env_ok 'type ralph'
}

# =============================================================================
# Sanity — no secrets or PII in tracked files
# =============================================================================

# Collect all config files to scan
pii_files() {
  echo "$HOME/.zshrc"
  echo "$HOME/.zshenv"
  echo "$HOME/.zprofile"
  echo "$BASHRC_DIR/.zshrc"
  find "$BASHRC_DIR/public" "$BASHRC_DIR/private" -type f \( -name '*.sh' -o -name '*.zsh' \) 2>/dev/null
}

@test "no secrets: no API keys with known prefixes" {
  run bash -c "pii_files() { $(declare -f pii_files | tail -n +2); }; pii_files | xargs grep -lE '\b(sk-[a-zA-Z0-9]{20,}|ghp_[a-zA-Z0-9]{36}|ghu_[a-zA-Z0-9]{36}|glpat-[a-zA-Z0-9]{20}|xox[bprs]-[a-zA-Z0-9-]{20,}|AKIA[0-9A-Z]{16}|phx_[a-zA-Z0-9]{20,}|sk-ant-[a-zA-Z0-9-]{20,}|sk_live_[a-zA-Z0-9]{20,})' 2>/dev/null"
  [ "$status" -ne 0 ]
}

@test "no secrets: no hardcoded secret assignments" {
  local pattern='(API_KEY|AUTH_TOKEN|SECRET_KEY|PASSWORD|PRIVATE_KEY|ACCESS_TOKEN|CLIENT_SECRET)=["'"'"']?[a-zA-Z0-9_/+=-]{8,}'
  run grep -rl -E "$pattern" "$HOME/.zshrc" "$HOME/.zshenv" "$HOME/.zprofile" "$BASHRC_DIR/.zshrc" "$BASHRC_DIR/public" "$BASHRC_DIR/private"
  [ "$status" -ne 0 ]
}

@test "no secrets: no bearer tokens" {
  run grep -rl -E 'Bearer [a-zA-Z0-9_/+=-]{20,}' "$HOME/.zshrc" "$HOME/.zshenv" "$HOME/.zprofile" "$BASHRC_DIR/.zshrc" "$BASHRC_DIR/public" "$BASHRC_DIR/private"
  [ "$status" -ne 0 ]
}

@test "no secrets: no SSH/PGP private keys" {
  run grep -rl -E 'BEGIN (RSA |DSA |EC |OPENSSH )?PRIVATE KEY' "$HOME/.zshrc" "$HOME/.zshenv" "$HOME/.zprofile" "$BASHRC_DIR/.zshrc" "$BASHRC_DIR/public" "$BASHRC_DIR/private"
  [ "$status" -ne 0 ]
}

@test "no secrets: no URLs with embedded credentials" {
  run grep -rl -E '://[a-zA-Z0-9_]+:[a-zA-Z0-9_]+@' "$HOME/.zshrc" "$HOME/.zshenv" "$HOME/.zprofile" "$BASHRC_DIR/.zshrc" "$BASHRC_DIR/public" "$BASHRC_DIR/private"
  [ "$status" -ne 0 ]
}
