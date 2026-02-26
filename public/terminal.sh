terminal() {
  local dir="$PWD"
  if [ $# -eq 0 ]; then
    osascript <<EOF
tell application "Terminal"
  activate
  do script "cd '$dir'"
end tell
EOF
  else
    local cmd="$*"
    osascript <<EOF
tell application "Terminal"
  activate
  do script "cd '$dir'; $cmd"
end tell
EOF
  fi
}

bgterminal() {
  local dir="$PWD"
  if [ $# -eq 0 ]; then
    osascript <<EOF
tell application "Terminal"
  do script "cd '$dir'"
end tell
EOF
  else
    local cmd="$*"
    osascript <<EOF
tell application "Terminal"
  do script "cd '$dir'; $cmd"
end tell
EOF
  fi
}