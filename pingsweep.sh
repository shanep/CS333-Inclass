#!/bin/bash


# Prints usage information
function usage() {
    cat <<EOF
Usage: $(basename "$0") [-h] [-p]

Options:
  -h    Show this help
  -p    Perform ping sweep of 200 onyxnode<N> hosts
EOF
    exit 0
}

# Pingsweep command for the Onyx nodes (small-scope change: scan 200 nodes)
function pingsweep_cmd() {
    local base="onyxnode"
    local count=200
    local logfile="ping.log"
    local i host out
    local found=0 missing=0

    : > "$logfile"    # truncate log

    for i in $(seq 1 "$count"); do
        host="${base}${i}"
        # mark host block in log, capture ping output while also appending to logfile
        echo "===HOST:$host" | tee -a "$logfile" >/dev/null
        out=$(ping -c 1 -W 1 "$host" 2>&1 | tee -a "$logfile")

        # parse success vs failure using regex (bytes from / icmp_seq / "1 received")
        if echo "$out" | grep -qE 'bytes from|icmp_seq=|1 received|1 packets received'; then
            echo "$host: reachable"
            found=$((found + 1))
        else
            echo "$host: unreachable"
            missing=$((missing + 1))
        fi
    done

    echo "Summary: found=$found missing=$missing"
}
