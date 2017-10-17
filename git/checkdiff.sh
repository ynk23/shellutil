#!/bin/bash

# [usage]
# ./chackdiff.sh <file>
#
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

dest='https://github.com/foo'
dest_alias="gh"
topdir=$(cd $(dirname $0) && pwd)
workdir="$topdir/mgws"
mkdir -p $workdir

for repo in $(cat $repolist | grep -v '^#')
do
  name=$(echo $repo | sed -e "s;^.*/;;")
  echo "--- start $name ---"
  cd $workdir && echo "[info] cd: current -> $(pwd)"
  if [ -d "$name" ]; then
    cd $name && echo "[info] cd: current -> $(pwd)"
    git fetch --all
  else
    git clone $repo $name
    cd $name && echo "[info] cd: current -> $(pwd)"
    git remote add ${dest_alias} "$dest/$name"
    git fetch --all
  fi
  git remote set-head origin -d
  echo ""
  echo "################ start check diff ###################"
  for obranch in $(git branch -r | grep "origin/")
  do
    branch=${obranch##origin/}
    if [ -n "$(git branch -r | grep ${dest_alias}/$branch)" ]; then # if exist ${dest_alias}/$branch
      ret="$(git diff --stat $dest_alias/$branch origin/$branch)"
      ret_num=$(echo -e "$ret" | wc -l)
      if [ 1 -eq $ret_num ]; then
        continue
      else
        echo "   >>> branch : $branch"
        echo -e "$ret"
        echo ""
      fi
    else # not exist ${dest_alias}/$branch
      echo "     >>> branch : $branch"
      echo "     only exixsts origin "
    fi
  done
done

exit 0
