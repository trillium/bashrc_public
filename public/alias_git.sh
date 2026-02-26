# alias ga='   f() { git add $@; git --no-pager status --short; };f'
alias ga='git add'
alias gaa='  git add --all; git --no-pager status --short'
alias gb='   git branch'
alias gc='   f() { git commit -m "$*"; };f'
alias gcnv=' gc --no-verify'
alias gcanv=' gc --amend --no-verify'
alias gcanvne=' gc --amend --no-verify'
alias gca='  git commit --amend -C HEAD'
alias gcae='  git commit --amend'
alias gcam=' f() { git commit --amend -m "$*"; };f'
alias gcp='  f() { git cherry-pick --no-commit $@; git --no-pager status --short; };f'
unalias gd 2>/dev/null
gd() { git difftool --gui "$@"; echo "--diff complete."; }
alias gdd='f() { git difftool --gui "$@"; echo "--diff complete."; }; f'
alias 'gd --staged'='echo "Reminder: Use gds instead"; git difftool --staged --gui'
alias gds='  git difftool --staged --gui'
# alias gdc='   git difftool --cached --gui; echo "--diff complete."'
alias gc='   git commit'
alias gcan='   git commit --amend --no-edit'
alias gdn='  git --no-pager diff --name-only'
alias gm='   git mergetool --gui'
alias gl='   git log --pretty=summary --use-mailmap'
alias gla='  git log --pretty=all     --use-mailmap --source --all'
alias gln='  git log --pretty=summary --name-status -n 5'
alias glf='  git --no-pager log --follow --oneline -- '
alias GO='   git checkout'
alias gpop=' git stash pop'
alias gpush='git stash push'
alias gpls=' git --no-pager stash list'
alias gs=' f() { local n=${1:-3}; git status --short; echo; git --no-pager log --pretty=summary -n $n; };f'
alias gsclip='git status --porcelain | clip'
alias gsls=' git status --porcelain | /usr/bin/cut -c4-'
# alias gh='   git show' # removing due to conflicts with gh cli
alias ghn='  git --no-pager show --name-status'
alias gri='  git rebase --interactive'
alias gra='  git rebase --abort'
alias gr-c='  git rebase --continue'
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

rebase() {
  # Define color codes
  GREEN='\033[0;32m'
  YELLOW='\033[1;33m'
  NC='\033[0m' # No Color

  # Stash all changes, including untracked files
  echo -e "${YELLOW}Stashing all changes, including untracked files...${NC}"
  stashed=$(git stash -u)

  # Get the current branch name
  # echo -e "${YELLOW}Getting the current branch name...${NC}"
  current_branch=$(git rev-parse --abbrev-ref HEAD)
  # echo -e "${GREEN}Current branch: $current_branch${NC}"

  # Use the current branch name in the git merge-base command
  # echo -e "${YELLOW}Finding the merge base between main and $current_branch...${NC}"
  merge_base=$(git merge-base main "$current_branch")
  # echo -e "${GREEN}Merge base commit: $merge_base${NC}"

  # Use the merge base commit hash in the git rebase command
  echo -e "${YELLOW}Starting interactive rebase from merge base commit{NC}"
  git rebase -i "$merge_base"

  # Apply the stashed changes
  if [[ "$stashed" == "No local changes to save" ]]; then
    echo -e "${YELLOW}Done!${NC}"
  else
    echo -e "${YELLOW}You can now run 'git stash pop' to retun stashed values${NC}"
  fi
}

# requires github CLI and proper setup
alias ghprme=' gh pr list --search "@trillium" '