#!/bin/bash

# [usage]
# ./sync.sh <file>
#
# switch comment-out/uncomment in line 40-43.
#  -- safety
#
# <file> is repository URL list.
# i.e.
#   |myreponameURL1
#   |myreponameURL2
#   |...
# if '#' head in line, then skip read the line.
# i.e.
#   |#myreoinameURL3
#   |##myreponameURL4


repolist=$1
[ -z $repolist ] && echo '[error] required argument.' && exit 1

dest='https://github.com/xxx'
topdir=$(cd $(dirname $0) && pwd)
workdir="$topdir/repos"
mkdir -p $workdir

for repo in `cat "$topdir/$repolist" | grep -v '^#'` # read line >> repo = myreponameURL[1,2,...]
do
  name=$(echo $repo | sed -e "s;^.*/;;") # e.g. https://github.com/foo/bar -> bar
  echo "--- start $name ---"
  cd $workdir && echo "[info] cd: current -> $(pwd)"
  if [ -d "$name" ]; then   # if exist git-dir
    cd $name && echo "[info] cd: current -> $(pwd)"
    git fetch --all         # update remote-tracking branch
  else                      # if not exist git-dir
    git clone --mirror $repo $name || ( echo "[error] error in 'git clone', skip clone $repo" && continue )
    cd $name && echo "[info] cd: current -> $(pwd)"
  fi
  git push --dry-run "$dest/$name" master    # dry-run, will not push
  git push --dry-run --mirror "$dest/$name"  # dry-run, will not push
  #git push -f "$dest/$name" master          # if uncomment, force push. (work-around)
  #git push -f --mirror "$dest/$name"        # if uncomment, force push.
done

exit 0
