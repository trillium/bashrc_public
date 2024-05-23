TALON_REPL_PATH=${TALON_REPL_PATH}

source ~/bashrc_dir/private/path.sh

function m() {
  # Check if Talon is asleep
  talon_state=$(state)
  if [[ "$talon_state" == "Talon is asleep" ]]; then
    # Wake up Talon
    echo "mimic(\"talon wake\")"| $TALON_REPL_PATH > /dev/null
    # Pipe a short sleep between each command
    echo "actions.sleep(.05)"| $TALON_REPL_PATH > /dev/null
  fi

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

  # If Talon was initially asleep, put it back to sleep
  if [[ "$talon_state" == "Talon is asleep" ]]; then
    # Pipe a short sleep between each command
    echo "actions.sleep(.05)"| $TALON_REPL_PATH > /dev/null
    # Put Talon to sleep
    echo "mimic(\"talon sleep\")"| $TALON_REPL_PATH > /dev/null
  fi
}

function M() {
  # Check if Talon is asleep
  talon_state=$(state)
  if [[ "$talon_state" == "Talon is asleep" ]]; then
    # Wake up Talon
    echo "mimic(\"talon wake\")"| $TALON_REPL_PATH > /dev/null
    # Pipe a short sleep between each command
    echo "actions.sleep(.05)"| $TALON_REPL_PATH > /dev/null
  fi

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

  # If Talon was initially asleep, put it back to sleep
  if [[ "$talon_state" == "Talon is asleep" ]]; then
    # Pipe a short sleep between each command
    echo "actions.sleep(.05)"| $TALON_REPL_PATH > /dev/null
    # Put Talon to sleep
    echo "mimic(\"talon sleep\")"| $TALON_REPL_PATH > /dev/null
  fi
}

export -f m
export -f M

function state() {
  # Capture the output of the actions.speech.enabled() command
  talon_state=$(echo "actions.speech.enabled()" | $TALON_REPL_PATH | tail -n 1)

  # Check if Talon is awake
  if [[ "$talon_state" == "True" ]]; then
    echo "Talon is awake"
  else
    echo "Talon is asleep"
  fi
}