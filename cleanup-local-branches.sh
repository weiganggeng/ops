# Remove local branches already merged into origin/main
DEFAULT=main   # or master
git fetch -p
git branch --merged "origin/$DEFAULT" \
  | egrep -v "^\*|$DEFAULT|develop|^release/|^hotfix/|staging|qa|integration" \
  | xargs -n 1 git branch -d
