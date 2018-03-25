#!/bin/sh
#	name : printRepositoryCommitNum.sh
#

## include function (source)
. function/getAllRepositories.sh

## variable
#	static final
#		VAR_FOO
#	static private
#		__varfoo
#	private and not static
#		_varfoo
#	private and short scope
#		varfoo
REPO_ROOT=/repo/gitbackup160422
_repositries=();
_allrepocommit=0;

## main logic
_repositories=( `getAllRepositories ${REPO_ROOT}` );
for repository in ${_repositories[@]}
do
	cd ${REPO_ROOT}/${repository};
	printf "#-------BEGIN REPOSITORY  : %-30s -----------#\n" ${repository};
	onerepocommit="`git log --all --since=1.years --format=%H | wc -l`";
	_allrepocommit="`expr ${_allrepocommit} + ${onerepocommit}`";
	printf "#-------      COMMIT      : %15i commit [%s]\n" ${onerepocommit} ${repository};
	printf "#-------END   REPOSITORY  : %-30s -----------#\n" ${repository};
done
printf "%i Byte\n" ${_allrepocommit};
