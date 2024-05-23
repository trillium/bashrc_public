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

alias ga='git add'

alias ga='   f() { git add $@; git --no-pager status --short; };f'
alias gaa='  git add --all; git --no-pager status --short'
alias gb='   git branch'
# alias gc='   f() { git commit -m "$*"; };f'
alias gc='   git commit'
alias gca='  git commit --amend -C HEAD'
alias gcam=' f() { git commit --amend -m "$*"; };f'
alias gcp='  f() { git cherry-pick --no-commit $@; git --no-pager status --short; };f'
# alias gd='   git difftool --gui; echo "--diff complete."'
alias gd='   git difftool --gui'
alias 'gd --staged'='echo "Reminder: Use gds instead"; git difftool --staged --gui'
alias gds='  git difftool --staged --gui'
# alias gdc='   git difftool --cached --gui; echo "--diff complete."'
alias gdn='  git --no-pager diff --name-only'
alias gm='   git mergetool --gui'
alias gl='   git log --pretty=summary --use-mailmap'
alias gla='  git log --pretty=all     --use-mailmap --source --all'
alias gln='  git log --pretty=summary --name-status -n 5'
alias glf='  git --no-pager log --follow --oneline -- '
alias go='   git checkout'
alias gpop=' git stash pop'
alias gpush='git stash push'
alias gpls=' git --no-pager stash list'
alias gs='   git status --short; echo; git --no-pager log --pretty=summary -n 3'
alias gsls=' git status --porcelain | /usr/bin/cut -c4-'
alias gh='   git show'
alias ghn='  git --no-pager show --name-status'
alias gri='  git rebase --interactive'
alias gra='  git rebase --abort'
alias grc='  git rebase --continue'
alias gr-d=' git fetch --prune && git rebase origin/dev'
alias gop='  git push origin -u'
alias gol='  git pull --ff-only'
alias gof='  f() { git fetch --prune $@; git gc --auto; };f'
alias clean='f() { find . -type d \( -name .git -o -name node_modules -o -name .next \) -prune -o -type f -name "*.orig" -print | xargs -I % rm %; git gc --aggressive; };f'

alias gyolo='ga . && git commit --amend --no-edit && git push --force'

# --- Additional git command
git config --global alias.pr '!f() { if [ $# -lt 1 ]; then
  echo "Usage: git pr <id> [<remote>] # assuming <remote>[=origin] is on GitHub";
  echo "    eg: git pr 1340 upstream";
  else git checkout -q "$(git rev-parse --verify HEAD)" &&
  git fetch -fv "${2:-origin}" pull/"$1"/head:pr/"$1" &&
  git checkout pr/"$1";
  fi; }; f'

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

function is_staged() {
  git diff --cached --quiet
  if [ $? -eq 0 ]; then
    echo "Nothing is staged."
  else
    echo "There are staged changes."
  fi
}

function print_line() {
  sed -n "${1}p" git_commit_commands_list.txt
}

function first_line() {
  head -n 1 "$1"
}

DATEFILE="/Users/trilliumsmith/code/100devs/dates.txt"
FUNCFILE="/Users/trilliumsmith/code/100devs/funcNames.txt"

function get_date() {
  # If the first argument passed to the function is "-l" or "--left"
  if [[ $1 == "-l" || $1 == "--left" ]]; then
      # Print the number of lines remaining in the DATEFILE
      # `wc -l < "$DATEFILE"` gets the total line count of DATEFILE
      echo "$(( $(wc -l < "$DATEFILE") - 1 )) lines remaining"
      return
  fi

  if [[ $1 == "-r" || $1 == "--redo" ]]; then
    # If -r or --redo flag is passed, print the first line
    head -n 1 "$DATEFILE"
  else
    # If no flag is passed, delete the first line and print the new first line
    sed -i '' '1d' "$DATEFILE"
    head -n 1 "$DATEFILE"
  fi
}

export -f get_date

function get_last_codewars() {
  head -n 1 "$FUNCFILE"
}

export -f get_last_codewars

function codewars() {
  # Insert funcName at the beginning of FUNCFILE
  sed -i '' "1i\\
$1
" "$FUNCFILE"

  local TESTSTRING=$(cat << EOF
import { test, expect } from 'vitest'
import { $1 } from './$1'

test('handle some tests', () => {
  expect($1(1111)).toBe(2222)
})
EOF
)

local FUNCSTRING=$(cat << EOF
export function $1(args) {
  // code here
}
EOF
)
  touch "$1.js"
  touch "$1.test.js"
  echo -e "$FUNCSTRING" >> "$1.js"
  echo -e "$TESTSTRING" >> "$1.test.js"
  code "$1.js"
  code "$1.test.js"
}

export -f codewars

alias standard__='git commit --date="$(get_date)" -m "feat: $(get_date -r) Add $(get_last_codewars).js and tests"'

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