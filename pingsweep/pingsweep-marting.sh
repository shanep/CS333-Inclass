#!/bin/bash


# Prints usage information
function usage() {
	echo "Usage: $0 -p"
	echo "Options:"
	echo "	-p    Ping sweep onyx nodes"
	echo "	-h    Show help message"
	exit 1
}

# Spinner function
spinner() {
    local PIDS=$1
    local spin_chars="/-\\|"
    while kill -0 "$PIDS" 2>/dev/null; do
        for i in {0..3}; do
            echo -en "${spin_chars:$i:1}"
            echo -en "\b" # Move cursor back one space
            sleep 0.1
        done
    done
    #echo -e "\b Done!"
}

# Pingsweep command for the Onyx nodes
function pingsweep_cmd() {
	local base="onyxnode"
	local found=0
	local total=0
	echo "Starting ping sweep..."

	for i in {1..200}; do 
		local node="${base}${i}"
		ping -c 1 "${node}" &> /dev/null
		if [ $? -eq 0 ]; then
			found=$((found + 1))
		fi
		total=$((total + 1))
	done

	local not_found=$((total - found))
	echo "BANG!!"
	echo "Nodes found: ${found}"
        echo "Nodes not found: ${not_found}"
}

function main() {
	while getopts ":hp" opt; do
		case ${opt} in
		h) usage ;;
		p) pingsweep_cmd ;;
		\?)
			echo "Invalid option: -$OPTARG" >&2
			usage
			;;
		esac
	done
	shift $((OPTIND -1))
}

##  Script entry point
if [ $# -eq 0 ]; then
	usage
else
	main "$@" &
	MAIN_PID=$!
	spinner $MAIN_PID
	wait $MAIN_PID
fi