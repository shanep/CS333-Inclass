#!/bin/bash

base="onyxnode"

usage () {
echo "Usage: ./pingsweep.sh <-h|-p>"
}

ping_sweeper () {
> ping.log
local total=0
local found=0
for i in {1..200}
do
        echo "$base$i"
        ping -c 1 -w 1 $base$i >> temp.log
	if [ $? -eq 0 ]; then
		echo "${base}${i} found." >> ping.log
		found=$((found+1))
	else
		echo "Node ${i} not found."
	fi
	total=$((total +1))
done
echo "Total nodes found: ${found} / ${total}" >> ping.log
rm -f temp.log
}

main () {
if [[ $# > 1 ]]; then
	usage
elif [[ $1 == "-h" ]]; then
	usage
elif [[ $1 == "-p" ]]; then
	echo = "Sweeping..."
	ping_sweeper
else
	usage
fi
}

main "$@"
