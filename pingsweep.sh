
#!/bin/bash
# Ping sweep the Lab

# progress bar - spinny bar
spinner='|/-\'
spin_i=0

spinner_show() {
    # $1 = current index, $2 = total, $3 = name
    local curr_index=$1
    local total=$2
    local name=$3
    printf "\r[%c] %3d/%d %s" \
        "${spinner:spin_i++%${#spinner}:1}" \
        "$curr_index" "$total" "$name"
}

spinner_clear() {
    printf "\r%-50s\r" ""
}

pingsweep() {
    # arrays to hold found and not found nodes
    local -a found=()
    local -a not_found=()

    # clear or create ping.log
    : > ping.log

    local base="onyxnode"

	for q in {1..200}
	do
        curr="$base$q"

		# spinner
        spinner_show "$q" 200 "$curr"

        # ping once with 1s wait, append output+errors to ping.log
        if ping -c 1 -W 1 "$curr" >> ping.log 2>&1; then
            found+=("$q")
        else
            not_found+=("$q")
        fi
    done

	# clear spinner line
	spinner_clear

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
