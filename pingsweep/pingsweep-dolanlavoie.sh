#!/bin/bash

usage(){
	echo "Usage: $0 [-h] [-p] <number_of_nodes>"
	exit 1
}

pingsweep() {
	base="onyxnode"
	prevProgress=""
	scanCount=$1
	failures=0
	successes=0
	> ping.log

	for ((n=1; n<=$scanCount; n++))
	do
		curr="$base$n"
		ping -c 1 $curr 2>&1 | tee -a ping.log
		if [ ${PIPESTATUS[0]} -eq 0 ];
		then
			prevProgress+="$curr is reachable\n"
			((successes++))
		else
			prevProgress+="$curr is not reachable\n"
			((failures++))
		fi
		percent=$(( (n * 100) / scanCount ))
		filled=$((percent / 2))
		empty=$((50 - filled))
		clear
		printf "$prevProgress"
		printf "\r["
		for ((i=0; i<filled; i++)); do printf "#"; done
		for ((i=0; i<empty; i++)); do printf " "; done
		echo "] $percent% ($n/$scanCount)"
	done

	echo "Scanned $scanCount nodes"
	echo "Failures: $failures"
	echo "Successes: $successes"
	echo "See ping.log for details"
	exit 0
}

displayHelp() {
	echo "./pingsweep.sh [-h] [-p] <number_of_nodes>"
	echo "[-h] Display help"
	echo "[-p] Perform a ping sweep on onyxnode1 to onyxnode200"
	exit 0
}

while getopts "hp:" o; 
do	
	case $o in
		h) displayHelp ;;
		p) pingsweep $OPTARG ;;
		\?) usage ;;
	esac
done

if [ $# -eq 0 ];
then 
	usage
fi
