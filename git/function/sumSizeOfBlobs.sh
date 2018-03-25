#!/bin/sh
# name : sumSizeOfBlobs.sh

# args[N]	: <string>...	blobs
# Return	: <int>		size
function sumSizeOfBlobs(){
	local _blobs=( $@ );
	local _blob;
	local _size;
	local _sizes=0;
	for _blob in ${_blobs[@]}
	do
		_size=`echo ${_blob} | git cat-file --batch="%(objecttype) %(objectsize)" | head -1 | awk '{print $2}'`;
		_sizes=`expr ${_sizes} + ${_size}`;
	done
	printf "%i\n" ${_sizes};
	return 0;
}
