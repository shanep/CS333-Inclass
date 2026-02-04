#!/bin/bash


function pingsweep_cmd() 
{
	local nodeFound=0
	local total=0
	local base="onyxnode"
	echo "Starting ping sweep..."
	for i in {1..10}; do 
		ping -c 1 "${base}${i}" &> ping.log
		if [ $? -eq 0 ]; then
			echo "${base}${i} is reachable."
			nodeFound=$((nodeFound+1))
		else
			echo "${base}${i} is not reachable."
			
		fi
		total=$((total+1))
	done
	echo "Found $nodeFound nodes reachable."
	echo "Nodes not reachable: $((total - nodeFound))"
	echo "Total nodes checked: $total"
}



cmd_help () 
{
	echo "Usage: pingsweep.sh -p"
	echo "Options:"
	echo "  -p    Perform a ping sweep of the lab nodes (onyxnode1 to onyxnode200)" 
}

function main() 
{
	while getopts ":ph" opt; do
		case $opt in
			p) pingsweep_cmd;;
			h) cmd_help ;;
			/?) 
			echo "Invalid option: -$OPTARG" >&2
			cmd_help ;;
		esac
	done
	shift $((OPTIND -1))
}

##script entry point
if [$# -eq 0 ]; then
	cmd_help
else
	main "$@"
fi
