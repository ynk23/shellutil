#!/bin/sh
# name : getTreeAsSha1.sh

# arg1		: <string>	commit
# Return	: <string>	tree
function getTreeAsSha1(){
	local _commit=$1;
	local _tree="`git cat-file -p ${_commit} | grep -E '^tree\s' | awk '{print $2}'`";
	local _crtdir="`pwd`";
	if [ "${#_tree}" -ne 40 ]; then
		echo "[ERROR] error occurred getTreeAsSha1." >&2;
		echo "";
		return 1;
	else
		echo "${_tree}";
	fi
	return 0;
}
