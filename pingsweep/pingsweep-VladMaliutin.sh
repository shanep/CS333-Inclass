#!/bin/bash

# ---------- Usage ----------
usage() {
    echo "Usage: $0 [-h] [-p <number_of_nodes>]"
    exit 1
}

# ---------- Help Menu ----------
displayHelp() {
    echo "Usage:"
    echo "  $0 [-h] [-p <number_of_nodes>]"
    echo
    echo "Options:"
    echo "  -h                    Display this help message"
    echo "  -p <number_of_nodes>  Ping sweep onyxnode1..onyxnodeN"
    echo
    echo "Examples:"
    echo "  $0 -h"
    echo "  $0 -p 200"
    exit 0
}

# ---------- Ping Sweep ----------
pingsweep() {
    base="onyxnode"
    prevProgress=""
    scanCount=$1
    failures=0
    successes=0

    > ping.log

    for ((n=1; n<=scanCount; n++))
    do
        curr="$base$n"

        ping -c 1 "$curr" 2>&1 | tee -a ping.log

        if [ ${PIPESTATUS[0]} -eq 0 ]; then
            prevProgress+="$curr is reachable\n"
            ((successes++))
        else
            prevProgress+="$curr is not reachable\n"
            ((failures++))
        fi

        percent=$(( (n * 100) / scanCount ))
        filled=$((percent / 2))
        empty=$((50 - filled))

        clear
        printf "$prevProgress"
        printf "\r["

        for ((i=0; i<filled; i++)); do printf "#"; done
        for ((i=0; i<empty; i++)); do printf " "; done

        echo "] $percent% ($n/$scanCount)"
    done

    echo
    echo "Scanned $scanCount nodes"
    echo "Failures: $failures"
    echo "Successes: $successes"
    echo "See ping.log for details"
}

# ---------- Option Parsing ----------
if [ $# -eq 0 ]; then
    usage
fi

while getopts ":hp:" o; do
    case "$o" in
        h)
            displayHelp
            ;;
        p)
            # Validate number input
            if ! [[ "$OPTARG" =~ ^[0-9]+$ ]]; then
                echo "Error: -p requires a number"
                usage
            fi
            pingsweep "$OPTARG"
            ;;
        \?)
            usage
            ;;
        :)
            usage
            ;;
    esac
done