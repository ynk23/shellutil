#!/bin/sh
# name : getAllRepositories.sh

# arg1		: <string>	repository root
# Return	: <string> ...	repositories
function getAllRepositories(){
	local _reporoot=$1;
	cd ${_reporoot};
	find . -maxdepth 1 -type d | sed -e 's|^\./||g' | grep -v '^\.';
	return 0;
} 
