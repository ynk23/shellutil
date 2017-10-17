#!/bin/bash

# スクリプト名
#	bashutil.sh
# bashで作成した関数集めました

function print(){
	# print meta-information
	local count=$1;
	local time=$(date --date @$2);
	local version="$3"
	echo "";
	echo "****----------------------------------------------------------****";
	echo "****     count   : $count";
	echo "****     version : $version";
	echo "****     time    : $time";
	echo "****----------------------------------------------------------****";
	return 0;
}

function errormail(){
	local bodyfile=$1;
	local subject="[debug][error]$0"
	if [[ ! -f $bodyfile ]]; then
		return 1;
	fi
	if [[ $(getfilesize $bodyfile) = 0 ]]; then
		return 1;
	fi
	source mail.conf;
	cat $bodyfile | mail -s $subject -r $mailfrom $mailto;
	return 0;
}

function rmfile(){
	local file;
	for file in $@
	do
		rm -f $file;
	done
	return 0;
}

function modeset(){
	if [[ $1 = inf ]]; then
		echo "UNLIMITED";
	else
		echo "LIMITED";
	fi
	return 0;
}

function getfilesize(){
	local file=$1;
	wc -c < $file;
	return 0;
}

function gettimenow(){
	local option=$1;
	local format;
	if [[ $option = --unix ]]; then
		format="+%s";
	elif [[ $option = --locale ]]; then
		format="+%X";
	elif [[ $option =~ ^--[a-z]+ ]]; then
		return 1;
	else
		format="";
	fi
	date $format;
	return 0;
}

function calcsum(){
	local num1=$1;
	local num2=$2;
	expr $num1 + $num2;
	return 0;
}

function exeeverysec(){
	checkargs $1 || return 1;
	local mode=$(modeset $1);
	# logger
	local logfile="$0.log";
	local errorlogfile="$0_error.log"
	# init
	rmfile $logfile $errorlogfile;
	local settingtime=$1;
	local elapsedtime=0;
	local time="";
	local logsize;
	while :
	# endless loop
	do
		elapsedtime=$(calcsum $elapsedtime 1 );
		timenow=$(gettimenow --unix);
		print $elapsedtime $timenow "$version" &>> $logfile;
		pushtag $timenow &>> $logfile;
		if [[ $? != 0 ]]; then
			print $elapsedtime $timenow &>> $errorlogfile;
			errormail $errorlogfile;
		fi
		if [[ $mode == "LIMITED" && $elapsedtime = $settingtime ]]; then
			break;
		fi
		# wait
		sleep 1;

		# logrotation
		logsize=$(getfilesize $logfile);
		if (( $logsize > 3000000 )); then #logsize > 3MB
			logrotation $logfile;
			logrotation $errorlogfile;
		fi
	done
}

function isNumeric(){
	if [[ $# != 1 ]];then
		return 1;
	fi
	expr "$1" + 1 >/dev/null 2>&1;
	if (( $? >= 2 )); then
		return 1;
	fi
	return 0;
}

function isNaturalNumber(){
	if ! isNumeric $1; then
		return 1;
	fi
	if (( $1 <= 0 )); then
		return 1;
	fi
	return 0;
}

function isInfinity(){
	if [[ $1 != inf ]]; then
		return 1;
	fi
	return 0;
}

function checkargs(){
	local sec=$1;
	if [[ -z $sec ]]; then
		echo "Usage : $0 <sec>|inf";
		return 1;
	fi
	if ! isNaturalNumber $sec && ! isInfinity $sec; then	
		echo "$sec is not Natural Number";
		echo "$sec is not String 'inf' (i.e. infinity)";
		return 1;
	fi
	return 0;
}

function getoldfiles(){
	local file=$1;
	local basename=${file%.*};
	local extention="${file##*.}"
	ls | grep -E "${basename}[0-9]*.${extention}";
	return 0;
}

function getnewfilename(){
	local file=$1;
	local oldfiles=( $(getoldfiles $file) );
	local numofolds=${#oldfiles[@]};
	local basename=${file%.*};
	local extention=${file##*.};
	local specific="$(calcsum $numofolds 1)";
	local newfilename="${basename}${specific}.${extention}";
	echo $newfilename;
	return 0;
}

function logrotation(){
	local logfile=$1;
	if [[ ! -e $logfile ]]; then
		return 1;
	fi
	local newlogfile=$(getnewfilename $logfile);
	mv $logfile $newlogfile;
	return 0;
}
