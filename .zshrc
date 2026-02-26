# shellcheck disable=SC1090,SC1091,SC2034
# SC1090/SC1091: shellcheck can't follow dynamic/~ sources (expected in .zshrc)
# SC2034: plugin/HELPDIR are used by zsh plugins, not directly

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

export GOBIN=$HOME/go/bin
export PATH=$PATH:$GOBIN
export PATH=$PATH:$HOME/go/bin

export HOMEBREW_AUTO_UPDATE_SECS=86400
export PATH="/homebrew/bin:$PATH"
export PATH="/opt/homebrew/bin:$PATH"

export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH"
export PIPENV_PYTHON="$PYENV_ROOT/shims/python"

source ~/bashrc_dir/private/path.sh

# pyenv — lazy-loaded (saves ~240ms). Full init runs on first use of pyenv/python/pip.
# __lazy_pyenv uses double-underscore so Claude Code shell snapshots capture it
# (snapshots filter out single-underscore functions, causing "command not found" errors).
__lazy_pyenv_done=0
__lazy_pyenv() {
  if (( __lazy_pyenv_done )); then
    return
  fi
  __lazy_pyenv_done=1
  unset -f pyenv python python3 pip pip3 2>/dev/null
  eval "$(command pyenv init -)"
  eval "$(command pyenv virtualenv-init -)"
}
pyenv()   { __lazy_pyenv; command pyenv "$@"; }
python()  { __lazy_pyenv; command python "$@"; }
python3() { __lazy_pyenv; command python3 "$@"; }
pip()     { __lazy_pyenv; command pip "$@"; }
pip3()    { __lazy_pyenv; command pip3 "$@"; }

# fnm (fast node manager) — reads .nvmrc, auto-switches on cd
eval "$(fnm env --use-on-cd --shell zsh)"

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
HELPDIR=/opt/homebrew/share/zsh/help
alias help=run-help

# thefuck aliases — auto-regenerates cache when binary is updated
_thefuck_cache=~/.cache/thefuck-aliases.zsh
_thefuck_bin=$(command -v thefuck)
if [[ ! -f "$_thefuck_cache" || "$_thefuck_bin" -nt "$_thefuck_cache" ]]; then
  thefuck --alias FUCK > "$_thefuck_cache" && thefuck --alias fuck >> "$_thefuck_cache"
fi
source "$_thefuck_cache"
unset _thefuck_cache _thefuck_bin

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


# --- Private sources ---
source ~/bashrc_dir/private/codewars.sh
# NOTE: private/path.sh is already sourced above

# --- Public sources ---
source ~/bashrc_dir/public/alias_general.sh
source ~/bashrc_dir/public/alias_git.sh
source ~/bashrc_dir/public/caddy_add.sh
source ~/bashrc_dir/public/cd.sh
source ~/bashrc_dir/public/edit.sh
source ~/bashrc_dir/public/find_and_replace.sh
source ~/bashrc_dir/public/forever.sh
source ~/bashrc_dir/public/gclone.sh
source ~/bashrc_dir/public/git_wrapper.sh
source ~/bashrc_dir/public/kill_port.sh
source ~/bashrc_dir/public/note.sh
source ~/bashrc_dir/public/num_to_word.sh
source ~/bashrc_dir/public/ralph.sh
source ~/bashrc_dir/public/talon_mimic.sh
source ~/bashrc_dir/public/terminal.sh
source ~/bashrc_dir/public/clip_error.sh
