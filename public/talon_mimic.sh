function m() {
  # begin an empty command
  command=""
  # loop over all arguments passed to the function
  for word in "$@"; do
    # If , or . are found at the end an argument
    if [[ "$word" == *, || "$word" == *. ]]; then
      # remove , or . from the argument
      word=$(echo "${word}" | tr -d ',.')
      # add the current argument to the command
      command="$command $word"
      # Remove leading whitespace
      command="${command#"${command%%[![:space:]]*}"}"
      # Remove trailing whitespace
      command="${command%"${command##*[![:space:]]}"}"
      # Pipe the command to the talon repl running mimic
      echo "mimic(\"${command}\")"| $TALON_REPL_PATH > /dev/null
      # Pipe a short sleep between each command
      echo "actions.sleep(.05)"| $TALON_REPL_PATH > /dev/null
      command="" 
    # if no , or . are found in the argument
    # append the argument to the command
    else
      command="$command $word"
    fi
  done
  # Run the last saved command
  echo "mimic(\"${command/ /}\")"| $TALON_REPL_PATH > /dev/null
}

function M() {
  # Change to the last used window
  echo "mimic(\"command tab\")"| $TALON_REPL_PATH > /dev/null
  # Send a short sleep
  echo "actions.sleep(.05)"| $TALON_REPL_PATH > /dev/null
  # Run commands after `M`
  m "$@"
  # Send a short sleep
  echo "actions.sleep(.05)"| $TALON_REPL_PATH > /dev/null
  # Restore back the original used window
  # (as long as no other window changing commands are used)
  echo "mimic(\"command tab\")"| $TALON_REPL_PATH > /dev/null
}

export -f m
export -f M