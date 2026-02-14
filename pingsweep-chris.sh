#!/bin/bash

# Prints usage information
usage() {
    cat <<EOF
Usage: $0 [-h] [-p]

Options:
  -h    Show this help menu
  -p    Run ping sweep on onyxnode hosts
EOF
    exit 0
}

# Ping sweep command for the Onyx nodes
pingsweep_cmd() {
    local base="@onyxnode"
    local count=200
    local logfile="ping.log"
    local found=0
    local missing=0

    echo "Starting ping sweep..."
    : > "$logfile"

    for i in $(seq 1 "$count"); do
        local node="${base}${i}"

        output=$(ping -c 1 -W 1 "$node" 2>&1 | tee -a "$logfile")

        if echo "$output" | grep -qE 'bytes from|1 received|1 packets received'; then
            echo "Node $node is reachable."
            found=$((found + 1))
        else
            echo "Node $node is not reachable."
            missing=$((missing + 1))
        fi
    done

    echo "Ping sweep complete."
    echo "Found: $found"
    echo "Missing: $missing"
}

main() {
    while getopts ":hp" opt; do
        case "$opt" in
            h)
                usage
                ;;
            p)
                pingsweep_cmd
                ;;
            \?)
                echo "Invalid option: -$OPTARG" >&2
                usage
                ;;
        esac
    done
}

# Script entry point
if [ $# -eq 0 ]; then
    usage
else
    main "$@"
fi
