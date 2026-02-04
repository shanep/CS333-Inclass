#!/bin/bash
# Ping sweep the Lab

base="onyxnode"

cmd_pingSweep() {
	for q in {1..200}
	do
		printf -v curr "%s%02d" "$base" "$q"
		ping -c 1 $curr >> ping.log
	done
}

cmd_help() {
	echo "-p to pingsweep"
}

usage() {
	echo "sh pingsweep <-h/-p>"
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

	if [ $# -lt 1 ]; then
		echo "Missing argument"
		usage
		exit 1
	else
		main "$@"
	fi

