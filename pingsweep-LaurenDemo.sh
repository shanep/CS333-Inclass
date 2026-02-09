#!/bin/bash
# Ping sweep the Lab

ping_sweep(){
        local base="onyxnode"
        local scanned=0
        local active=0
        local unresponsive=0
        for q in {1..200}
        do
                host="onyxnode$q"
                printf "\r"; spin "$q";
                printf "%d out of 200" "$q"
                scanned=$((scanned+1))
                if ping -c 1 -W 1 "$host" >> ping.log 2>&1; then
                        active=$((active+1))
                else
                        unresponsive=$((unresponsive+1))
                fi
        done
        echo -e "\nScanned $scanned nodes"
        echo "Found $active active machines"
        echo "No response $unresponsive machines"
        return
}

spin(){
        local i=$(($1 % 4))
        local spin='|/-\\'
        printf "${spin:$i:1}" "$1"

}
# have a help menu
help(){
	echo "Usage: pingsweep.sh [-p] [-h]"
	echo "Options:"
	echo "  -p    Run ping sweep"
	echo "  -h    Show this help menu"
	exit 1
}

# add a flag -p to run it
while getopts "ph" opt; do
	case $opt in
		p)
			ping_sweep
			;;
		h)
			help
			;;
		*)
			help
			;;
	esac
done

