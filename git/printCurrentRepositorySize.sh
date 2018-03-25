#!/bin/sh
#	name : printCurrentRepositorySize.sh
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
_allreposize=0;

## main logic
_repositories=( `getAllRepositories ${REPO_ROOT}` );
for repository in ${_repositories[@]}
do
	cd ${REPO_ROOT}/${repository};
	printf "#-------BEGIN REPOSITORY  : %-30s -----------#\n" ${repository};
	onereposize="`du -sb | awk '{print $1}'`";
	_allreposize="`expr ${_allreposize} + ${onereposize}`";
	printf "#-------      SIZE        : %15i Byte [%s]\n" ${onereposize} ${repository};
	printf "#-------END   REPOSITORY  : %-30s -----------#\n" ${repository};
done
printf "%i Byte\n" ${_allreposize};
