#!/usr/bin/env bash
# audit-shell-usage.sh — Cross-reference shell profile definitions against zsh history
# Run: ./tests/audit-shell-usage.sh [--recent N]
#
# Outputs a usage report showing which custom aliases/functions are actually used.
# Re-run periodically to track what's worth keeping.

set -euo pipefail
export LC_ALL=C

HISTFILE="${HISTFILE:-$HOME/.zsh_history}"
RECENT="${1:-}"
RECENT_N="${2:-1000}"

if [[ "$RECENT" == "--recent" ]]; then
  echo "=== Shell Usage Audit (last $RECENT_N history entries) ==="
  echo "    Date: $(date '+%Y-%m-%d')"
  HIST_CMD="tail -${RECENT_N} '$HISTFILE'"
else
  echo "=== Shell Usage Audit (all-time) ==="
  echo "    Date: $(date '+%Y-%m-%d')"
  echo "    History entries: $(wc -l < "$HISTFILE")"
  HIST_CMD="cat '$HISTFILE'"
fi
echo ""

# Build command frequency table
counts_file=$(mktemp)
eval "$HIST_CMD" | awk -F';' '{if(NF>1) print $2; else print $0}' \
  | awk '{print $1}' | grep -E '^[a-zA-Z]' | sort | uniq -c | sort -rn > "$counts_file"

lookup() {
  local cmd="$1"
  local count
  count=$(grep -w "^[[:space:]]*[0-9]* ${cmd}$" "$counts_file" 2>/dev/null | awk '{print $1}')
  echo "${count:-0}"
}

# --- Report sections ---

section() {
  echo ""
  echo "--- $1 ---"
  printf "  %-25s %s\n" "COMMAND" "USES"
}

report_line() {
  local cmd="$1"
  local note="${2:-}"
  local count
  count=$(lookup "$cmd")
  if [[ -n "$note" ]]; then
    printf "  %-25s %-6s  %s\n" "$cmd" "$count" "$note"
  else
    printf "  %-25s %s\n" "$cmd" "$count"
  fi
}

section "alias_general.sh — General aliases"
report_line py
report_line reload
report_line pbclip
report_line copy
report_line clip
report_line clip.get
report_line clip.set
report_line paste
report_line yarm
report_line ydev
report_line pnpmd
report_line pdev
report_line pd
report_line ptest
report_line pt
report_line pbuild
report_line pb
report_line ya
report_line cdcode
report_line rcode
report_line ask
report_line brun
report_line bdev
report_line btest
report_line bbuild

section "alias_git.sh — Git aliases"
report_line ga
report_line gaa
report_line gb
report_line gc
report_line gcnv
report_line gcanv
report_line gcanvne
report_line gca
report_line gcae
report_line gcam
report_line gcp
report_line gdd
report_line gds
report_line gdn
report_line gm
report_line gl
report_line gla
report_line gln
report_line glf
report_line GO
report_line gpop
report_line gpush
report_line gpls
report_line gs
report_line gsclip
report_line gsls
report_line ghn
report_line gri
report_line gra
report_line gr-c
report_line gr-d
report_line gop
report_line gol
report_line gof
report_line clean
report_line gyolo
report_line ghprme
report_line gitpru
report_line rebase
report_line gd

section "cd.sh — Navigation"
report_line dc
echo "  (.. / ... / .... / ..... are not trackable in history)"

section "Custom functions — Entry points"
report_line edit "edit.sh"
report_line do_find "find_and_replace.sh"
report_line do_replace "find_and_replace.sh"
report_line forever "forever.sh"
report_line gclone "gclone.sh"
report_line KILL "kill_port.sh"
report_line note "note.sh"
report_line ralph "ralph.sh"
report_line terminal "terminal.sh"
report_line bgterminal "terminal.sh"
report_line penguin "penguin/penguin.sh"

section "Custom functions — Talon voice control"
report_line m "entry point → get_state, mimic_arg_loop"
report_line M "entry point → get_state, repl_mimic, repl_func, mimic_arg_loop"
report_line nm "entry point → get_state, mimic_arg_loop_nums_to_words"
report_line NM "entry point → get_state, repl_mimic, repl_func, mimic_arg_loop_nums_to_words"
echo "  (internal helpers: get_state, repl_func, repl_mimic, mimic_arg_loop — usage inherited from above)"

section "Custom functions — num_to_word.sh (dependency of nm/NM)"
report_line num_to_word "called by mimic_arg_loop_nums_to_words"
report_line has_numeric_values "called by mimic_arg_loop_nums_to_words"
report_line n "alias for num_to_word"

section "Custom functions — Caddy local domains"
report_line caddy-add
report_line caddy-list
report_line caddy-remove
report_line caddy-edit
report_line caddy-reload
report_line caddy-status "calls caddy-list internally"

section "Custom functions — Codewars (private)"
report_line codewars
report_line get_date "called by standard__ alias"
report_line get_last_codewars "called by standard__ alias"
report_line standard__
report_line is_staged
report_line print_line
report_line first_line

section "Misc"
report_line codetalon "private/path.sh alias"
report_line we_did_it_wooooo "~/.zshrc alias"

rm -f "$counts_file"

echo ""
echo "=== Done ==="
echo "Re-run with --recent 1000 to see only recent usage."
