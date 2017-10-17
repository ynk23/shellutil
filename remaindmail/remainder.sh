#!/bin/bash

## mail process を kill するのを忘れないように 17:20になったら
## mail.conf のアドレスにメールを送信する

function calcdiff(){
	local sec1=$1;
	local sec2=$2;
	expr $sec1 - $sec2;
	return 0;
}

function remaindmail(){
	source mail.conf;
	local body="プロセスをKILLするのを忘れずに帰りましょう";
	local title="[debug][remailder]inv_pushtag.sh";
	echo $body | mail -s $title -r $mailfrom $mailto;
}

function isLimitTime(){
	local time="16:00";
	local now=$(date "+%s");
	local today=$(date "+%Y%m%d");
	local limit=$(date --date "$today $time" "+%s");
	if (( $(calcdiff $limit $now) >= 0 )); then
		return 1;
	fi
	return 0;
}

function watch(){
	while :
	do
		if isLimitTime ;then
			remaindmail;
			break;
		else
			sleep 1;
		fi
	done
}

watch;
