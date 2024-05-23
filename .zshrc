export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
export PIPENV_PYTHON="$PYENV_ROOT/shims/python"

source ~/bashrc_dir/private/path.sh

plugin=(
  pyenv
)

eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

export NVM_DIR=~/.nvm
source $(brew --prefix nvm)/nvm.sh

# place this after nvm initialization!
autoload -U add-zsh-hook
load-nvmrc() {
  local nvmrc_path="$(nvm_find_nvmrc)"

  if [ -n "$nvmrc_path" ]; then
    local nvmrc_node_version=$(nvm version "$(cat "${nvmrc_path}")")

    if [ "$nvmrc_node_version" = "N/A" ]; then
      nvm install
    elif [ "$nvmrc_node_version" != "$(nvm version)" ]; then
      nvm use
    fi
  elif [ -n "$(PWD=$OLDPWD nvm_find_nvmrc)" ] && [ "$(nvm version)" != "$(nvm version default)" ]; then
    echo "Reverting to nvm default version"
    nvm use default
  fi
}
add-zsh-hook chpwd load-nvmrc
load-nvmrc

alias py="python"

alias reload="source ~/bashrc_dir/.zshrc"
alias pbclip="pbcopy"
##
##
# alias gs='git status'
# alias gpuo='git push -u origin'
# alias gcm='git commit -m'
# alias gd='git diff'
# alias gl='git log'
# alias ga='git add'

alias yarm='yarn'
alias ydev='yarn dev'
alias ya='yarn add'

# git config --global alias.pr '!f() { if [ $# -lt 1 ]; then echo "Usage: git pr <id> [<remote>]  # assuming <remote>[=origin] is on GitHub"; else git checkout -q "$(git rev-parse --verify HEAD)" && git fetch -fv "${2:-origin}" pull/"$1"/head:pr/"$1" && git checkout pr/"$1"; fi; }; f'

# test bash rename git command
function do_find() {
  for file in *.js                                                 
  do
          if [[ "${file}" == *"test"* ]]
          then
            echo ❌ "${file}" "${file%.js}.jsx"
            continue
          fi
          # git mv "$file" "${file%.js}.jsx"
          echo ✅ "${file}" ' --> ' "${file%.js}.jsx"

  done
  # echo "did a rename from .js to .jsx"
}

function do_replace() {
  for file in *.js                                                 
  do
          if [[ "${file}" == *"test"* ]]
          then
            echo ❌ "${file}" "${file%.js}.jsx"
            continue
          fi
          git mv "$file" "${file%.js}.jsx"
          echo ✅ "${file}" ' --> ' "${file%.js}.jsx"

  done
  # echo "did a rename from .js to .jsx"
}

export -f do_replace

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

function hello() {
  arg_count=$#
  
  for arg in "$@"; do
    if [[ "$arg" == *,* ]]; then
      echo "Argument '$arg' contains a comma"
    fi
  done

  echo "Hello, $@! ($arg_count arguments)"
}

export -f hello

# --- editor
alias c='code -g'

alias ..='cd .. && ls'
alias ...='.. && .. && ls'
alias ....='... && .. && ls'
alias .....='.... && .. && ls'
# alias cd='  f() { cd $@; ls };f'
alias dc='  f() { cd $@; ls };f'

# --- editor
which pico  >/dev/null 2>&1 && export EDITOR='pico'
which nano  >/dev/null 2>&1 && export EDITOR='nano'
which code  >/dev/null 2>&1 && export EDITOR='code -g --wait' && alias c='code -g'
# which dircolors  >/dev/null 2>&1 && dircolors --bourne-shells

# -- typos
# doesn't work
# alias "yarn insatll"='install'

# alias profile='code  ~/.bash_profile' ## unneeded
alias edit='code /Users/trilliumsmith/bashrc_dir/.zshrc'
alias zshrc='code ~/.zshrc'
alias antigenrc='code ~/.antigenrc'

##

# Ruby - chruby
# https://github.com/postmodern/chruby

# source /usr/local/share/chruby/chruby.sh
# source $HOMEBREW_PREFIX/opt/chruby/share/chruby/chruby.sh # Or run `brew info chruby` to find out installed directory
# source /opt/homebrew/opt/chruby/share/chruby/auto.sh
source /opt/homebrew/opt/chruby/share/chruby/chruby.sh
source /opt/homebrew/opt/chruby/share/chruby/auto.sh
chruby ruby-3.2.2

# Create a help alias
unalias run-help
autoload run-help
HELPDIR=$(command brew --prefix)/share/zsh/help
alias help=run-help

#thefuck command -- insatlled by brew
eval $(thefuck --alias FUCK)
eval $(thefuck --alias fuck)

# Load Antigen
source /opt/homebrew/share/antigen/antigen.zsh

# Load Antigen configurations
antigen init ~/.antigenrc

##
echo "Loaded .zshrc"

# Created by `pipx` on 2023-11-20 07:30:03
export PATH="$PATH:/Users/trilliumsmith/.local/bin"

# pnpm
export PNPM_HOME="/Users/trilliumsmith/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
PATH=~/.console-ninja/.bin:$PATH


declare -a loaded_files_basename
declare -a loaded_files

for file in ~/bashrc_dir/private/*.sh
do
  source "$file"
  loaded_files_basename+=("Loaded Private: $(basename $file)")
  loaded_files+=$file
done

for file in ~/bashrc_dir/public/*.sh
do
  source "$file"
  loaded_files_basename+=("Loaded Public : $(basename $file)")
  loaded_files+=$file
done

# Clear function definition bloat
clear

# Loop over array and print the names of the loaded files
for file in "${loaded_files[@]}"
do
  echo "$file"
done