#!/bin/bash
# Ping sweep the Lab

# base="onyxnode"

function printHelp(){
	echo "Ping Sweep for Onyx nodes script overview:"
	echo "Usage: $0 [-h] [-p]"
	echo "[-h] Displays this help menu and exits program."
	echo "[-p] Ping sweeps through all avaiable Onyx nodes from onyxnode1 to 200 and then logs the results to a file"
}

function pingSweep(){
	local base="onyxnode"
	local found=0;
	local curr=0;
	echo "Pinging Nodes... TBD"
	for i in {1..10}; do
		local node="${base}${i}"
		ping -c 1 -W 1 "${node}" >> pingLog.txt
		if [ $? -eq 0 ]; then
			echo "Node ${node} is reachable"
			found=$((found + 1))
		else
			echo "Node ${node} is unreachable"
		fi
		total=$((total + 1))
	done
	echo "Pingsweep done. Found ${found} reachable nodes"
}


function main(){
	while getopts ":hp" opt; do
		case ${opt} in
		h) printHelp ;;
		p) pingSweep ;;
		\?) 
			echo "Invalid option detected! -$OPTARG" >&2
			printHelp
			;;

		esac
	done
	shift $((OPTIND -1))
}

#Script entry point
if [ $# -eq 0 ]; then
	printHelp
else
	main "$@"
fi
