# export PATH="$HOME/.pyenv/shims:$PATH"
# export PYENV_ROOT="$HOME/.pyenv"
# export PATH="$PYENV_ROOT/bin:$PATH"
# export PIPENV_PYTHON="$PYENV_ROOT/shims/python"

# source ~/bashrc_dir/private/path.sh

# # plugin=(
# #   pyenv
# # )

# # eval "$(pyenv init -)"
# # eval "$(pyenv virtualenv-init -)"

# echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.zshrc
# echo '[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.zshrc
# echo 'eval "$(pyenv init -)"' >> ~/.zshrc

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

# --- editor
alias c='code -g'

# --- editor
which pico  >/dev/null 2>&1 && export EDITOR='pico'
which nano  >/dev/null 2>&1 && export EDITOR='nano'
which code  >/dev/null 2>&1 && export EDITOR='code -g --wait' && alias c='code -g'
# which dircolors  >/dev/null 2>&1 && dircolors --bourne-shells

# alias profile='code  ~/.bash_profile' ## unneeded
alias zshrc='code /Users/trilliumsmith/bashrc_dir/.zshrc'
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


# Subfile loader
declare -a loaded_files_basename
declare -a loaded_files
# Clear the arrays incase reload was called (makes duplicates)
loaded_files_basename=()
loaded_files=()

# Add in this .zshrc filepath
loaded_files+=("$0")

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

# Clear function definition bloat from export -f
clear

# Loop over array and print the names of the loaded files
for file in "${loaded_files_basename[@]}"
do
  echo "$file"
done

echo
echo "Termianl read in:"
echo | pwd