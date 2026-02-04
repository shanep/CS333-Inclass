#!/bin/bash
# Ping sweep the Lab

base="onyxnode"

cmd_pingSweep() {
	local found=0
	local total=0
	for q in {1..200}
	do
		curr="$base$q"
		ping -c 1 -w 1 $curr &> /dev/null
	  if [ $? -eq 0 ]; then 
		echo "Node ${curr} is reachable."
		found=$((found + 1))
	  else
		echo "Node ${curr} is not reachable."
	  fi
	total=$((total + 1))
	done
}

cmd_help() {
	echo "-p to pingsweep"
}

main(){
	for cmd in "$@"; do
		case "$cmd" in
			-h) cmd_help ;;
			-p) cmd_pingSweep ;;
			*)
				echo "Unknown command: $cmd"
				cmd_help
				exit 1
				;;
		esac
	done
}

main "$@"

