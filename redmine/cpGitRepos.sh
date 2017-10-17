#!/bin/bash

## Summary.
## copy Git repositories currently-operated environment to system-test environment.
## origin - ***
## root repository
##   <list-repository>
##   url : <redmine-url> 
## root repository's branch
##   branch
## read
##   list.csv
## get
##   All repositorys that stated by the read files.
## cp to Git repositories
##   <git-url>
##

function usage(){
cat << EOU
invalid args.
usage : $(basename $0) -m|-s
  -m  : cp mainrepository. ex. xxx
  -s  : cp subrepository. ex. xxx.yyy
EOU
}

## 0. set parm
while getopts ms option
do
  case ${option} in
    m) targetismain=true;;
    s) targetismain=false;;
    *) usage ; exit 1 ;;
  esac
done
if [[ -z ${targetismain} ]]; then
  usage; exit 1
fi

## 1. set Git confidential
echo -n "set git user id : "
read uid
echo -n "set git password : "
read pass
echo "uid : ${uid}"
echo "pass : ${pass}"
if ${targetismain}; then
  echo "option : m -> cp main repository. create redmine project and cp Git repositories."
else
  echo "option : s -> cp sub repository. NOT create redmine project and cp Git repositories. if you already add manually new repositories in main repository project, then select y. otherwise select no. "
fi
echo -n "continue? y/n : "
read type
if [ ! ${type} = y ] ;then
echo "select ${type}. break."
exit 0
fi
fhost="http://${uid}:${pass}@<host>"
thost="http://demouser:password@<host>"

## 2. get repolist repository.
mkdir -p ./cpGitRepos/
rm -rf ./cpGitRepos/*
cd ./cpGitRepos
git clone -b <branch> ${fhost}/git/<list-repository> <list-repository>

## 3. load url-identifier and branch of repository repositories.
declare -A mainmod
declare -A submod
declare -A errmod
cd <list-repository>
for line in $(cat list.csv)
do
  echo "${line}"
  base=${line%,*}
  url=${base%%,*}
  urlid=${url##*/}
  branch=${base##*,}
  echo "urlid : ${urlid}"
  echo "branch: ${branch}"
  if [[ ${urlid} == *.* ]] ; then
    if [[ ${urlid} != *. ]] && [[ ${urlid} != .* ]]; then
      submod["${urlid}"]="${branch}"
    else
      errmod["${urlid}"]="${branch}"
    fi
  else
    mainmod["${urlid}"]="${branch}"
  fi
done
cd -
rm -rf <list-repository>

## 4. output files.
rm -f execute.out not_execute.out error.out
for key in ${!mainmod[@]}
do
  printf "id : %-25s | branch : %s\n" ${key} ${mainmod["${key}"]} >> execute.out
done
for key in ${!submod[@]}
do
  printf "id : %-25s | branch : %s\n" ${key} ${submod["${key}"]} >> not_execute.out
done
for key in ${!errmod[@]}
do
  printf "id : %-25s | branch : %s\n" ${key} ${errmod["${key}"]} >> error.out
done

## 5. create Redmine project
## note. only $mainmod
if ${targetismain}; then
  for key in ${!mainmod[@]}
  do
    ruby ../createRedmineProj.rb ${key} ${key}
  done
fi

## 6. cp git repository
if ${targetismain}; then
  for key in ${!mainmod[@]}
  do
    git clone -b ${mainmod[${key}]} ${fhost}/git/${key} ${key}
    cd ${key}
    git push ${thost}/git/${key} ${mainmod[${key}]}:<branch>
    cd -
    rm -rf ${key}
  done
else
  for key in ${!submod[@]}
  do
    git clone -b ${submod[${key}]} ${fhost}/git/${key} ${key}
    cd ${key}
    git push ${thost}/git/${key} ${submod[${key}]}:<branch>
    cd -
    rm -rf ${key}
  done
fi

## FINALLY
echo "#############################################################"
echo "########################  SUMMARY ###########################"
echo "output cp execute repository     : ~/cpGitRepos/execute.out"
echo "output cp not_execute repository : ~/cpGitRepos/not_execute.out"
echo "output cp error repository       : ~/cpGitRepos/error.out"
echo ""
echo "############################################################"
echo ""
echo "####################### ATTENTION!! ########################"
echo "####   please manual add follow Git SUB repositories.   ####"
echo ""
cat ./not_execute.out
echo "########################### END ############################"
