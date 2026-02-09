#!/bin/bash
# Ping sweep the Lab

base="onyxnode"

cmd_pingSweep() {
	local found=0
	local total=0
	for q in {1..200}
	do
		printf -v curr "%s%02d" "$base" "$q"
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
	echo "-u usage"
}

cmd_usage() {
	echo "sh pingsweep <-h/-p>"
}

main(){
	for cmd in "$@"; do
		case "$cmd" in
			-h) cmd_help ;;
			-p) cmd_pingSweep ;;
			-u) cmd_usage ;;
			*)
				echo "Unknown command: $cmd"
				cmd_help
				exit 1
				;;
		esac
	done
}

	if [ $# -lt 1 ]; then
		echo "Missing argument"
		usage
		exit 1
	else
		main "$@"
	fi

