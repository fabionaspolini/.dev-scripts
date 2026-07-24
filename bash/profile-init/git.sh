alias gf="git fetch --prune"
alias gp="git pull --prune"
alias gr="git remote -v"
alias gs="git status"
alias git-get-all-branchs='git branch -r | grep -v "\->" | while read remote; do git branch --track "${remote#origin/}" "$remote"; done'
