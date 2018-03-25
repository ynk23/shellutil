#!/bin/sh
# name : getBlobsAsSha1.sh

# arg1		: <string>	tree
# Return	: <string>...	blobs
function getBlobsAsSha1(){
	local _tree=$1;
	local _subtrees=( `git cat-file -p ${_tree} | grep -E '\stree\s' |  awk '{print $3}'` );
	local _subtree;
	git cat-file -p ${_tree} | grep -E '\sblob\s' | awk '{print $3}';
	if [ "${PIPESTATUS[0]}" -ne 0 ]; then
		echo "[ERROR] error occurred getBlobs" >&2;
		return 1;
	fi
	if [ "${#_subtrees[@]}" -ne 0  ];then
		for _subtree in ${_subtrees[@]}
		do
			if [ "${#_subtree}" -ne 40 ]; then
				echo "[ERROR] error occured getBlobs [ tree : ${_tree} , subtree : ${_subtree} ]" >&2;
				return 1;
			fi
			getBlobsAsSha1 "${_subtree}" || return 1;
		done
	fi
	return 0;
}
