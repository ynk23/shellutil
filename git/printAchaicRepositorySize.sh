#!/bin/sh
#	name : printArchaicRepositorySize.sh
#

## include function (source)
. function/getAllRepositories.sh
. function/getCommitAsSha1.sh
. function/getTreeAsSha1.sh
. function/getBlobsAsSha1.sh
. function/sumSizeOfBlobs.sh

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
	printf "#-------BEGIN REPOSITORY  : %-30s -----------#\n" ${repository};
	cd ${REPO_ROOT}/${repository};
	commit=`getCommitAsSha1`;
	if [ "${commit}" = "" ]; then
		onereposize="0";
	else
		tree=`getTreeAsSha1 ${commit}`;
		blobs=( `getBlobsAsSha1 ${tree}` );
		onereposize=`sumSizeOfBlobs ${blobs[@]}`;
	fi;
	_allreposize=`expr ${_allreposize} + ${onereposize}`;
	printf "#-------      SIZE        : %15i Byte [%s]\n" ${onereposize} ${repository};
	printf "#-------END   REPOSITORY  : %-30s -----------#\n" ${repository};
done
printf "%i Byte\n" ${_allreposize};
