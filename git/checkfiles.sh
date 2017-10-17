#! /bin/bash
dir=$1
file=$2
[ -z "$dir" ] && echo '[error] required argument.'
[ -z "$file" ] && echo '[error] required argument.'

declare hits

cd $dir
branches=$(git branch -a | sed -e 's|remotes/origin/||' | grep -v 'HEAD' | grep -v '*')
for branch in $branches
do
echo ---- checkout $branch ------
git checkout -q $branch || echo '[error] checkout failed.'
res_ls_files=$(git ls-files $file)
[ -n "${res_ls_files}" ] && hit_branch="${branch}\n${hits}" && echo 'hit!'
done
echo '###### search result ######'
echo -e "${hits}"

exit 0
