# alias ga='   f() { git add $@; git --no-pager status --short; };f'
alias ga='git add'
alias gaa='  git add --all; git --no-pager status --short'
alias gb='   git branch'
alias gc='   f() { git commit -m "$*"; };f'
alias gca='  git commit --amend -C HEAD'
alias gcam=' f() { git commit --amend -m "$*"; };f'
alias gcp='  f() { git cherry-pick --no-commit $@; git --no-pager status --short; };f'
alias gd='   git difftool --gui; echo "--diff complete."'
alias 'gd --staged'='echo "Reminder: Use gds instead"; git difftool --staged --gui'
alias gds='  git difftool --staged --gui'
# alias gdc='   git difftool --cached --gui; echo "--diff complete."'
alias gc='   git commit'
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

gitpru() {
  if [ -z "$1" ]; then
    echo "Usage: gitpru NUMBER"
  else
    git pr "$1" upstream
  fi
}
