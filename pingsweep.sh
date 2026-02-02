#!/bin/bash
# Ping sweep the Lab

spinner_start() {
    spinner='|/-\'
    spin_i=0
    while true; do
        printf "\r[%c] Pinging %s" "${spinner:spin_i++%${#spinner}:1}" "$1"
        sleep 0.1
    done
}


pingsweep() {
	base="onyxnode"

	for q in {1..200}
	do
        curr="$base$q"

		# start spinner in background
		spinner_start "$curr" &
		SPINNER_PID=$!

        # ping once with 1s wait, append output+errors to ping.log
        if ping -c 1 -W 1 "$curr" >> ping.log 2>&1; then
            found+=("$q")
        else
            not_found+=("$q")
        fi
    done

	# stop spinner
    spinner_stop "$SPINNER_PID"

    # print summary to terminal
    echo
    echo "Ping sweep summary:"
    echo "  Found (${#found[@]}): ${found[*]}"
    echo "  Not found (${#not_found[@]}): ${not_found[*]}"

    # append summary to log as well
    {
        echo
        echo "Ping sweep summary:"
        echo "  Found (${#found[@]}): ${found[*]}"
        echo "  Not found (${#not_found[@]}): ${not_found[*]}"
    } >> ping.log
}

help() {
   # Display Help
   echo "Usage: pingsweep.sh [options]"
   echo
   echo "Syntax: pingsweep.sh [-p|h]"
   echo "options:"
   echo "h     Print the help menu."
   echo "p     Run the pingsweep function."
   echo
}

# If no arguments were provided, show help and exit
if [ $# -eq 0 ]; then
   help
   exit 0
fi

# parse the command line options
while getopts "hp" option; do
   case $option in
	  h) # display help
		 help
		 ;;
	  p) # run pingsweep
		 pingsweep
		 ;;
	  *) # Invalid option
		 echo "Error: Invalid option"
		 help
		 exit;;
   esac
done