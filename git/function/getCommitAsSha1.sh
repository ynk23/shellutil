#!/bin/sh
# name : getCommitAsSha1.sh

# Return	: <string>	: commit
function getCommitAsSha1(){
	# get oldest commit
	local _commit="`git log --all --reverse --format='%H' | head -1`";
	if [ "${#_commit}" -ne 40 ]; then
		echo "[ERROR] error occurred in getCommitAsSha1" >&2;
		echo "";
		return 1;
	else
		echo "${_commit}";
	fi
	return 0;
}
