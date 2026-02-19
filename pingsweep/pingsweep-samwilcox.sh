#!/usr/bin/env bash

progress_bar() {
    local current=$1
    local total=$2
    local width=40

    if [[ $total -eq 0 ]]; then
        total=1
    fi

    percent=$(( current * 100 / total ))
    filled=$(( percent * width / 100 ))
    empty=$(( width - filled ))

    bar=$(printf "%${filled}s" | tr ' ' '#')
    space=$(printf "%${empty}s")

    printf "\rScanning: [${bar}${space}] %d%% (%d/%d)" "$percent" "$current" "$total"
}

init_progress() {
    GLOBAL_TOTAL=$1
    GLOBAL_PROGRESS=0
}

increment_progress() {
    ((GLOBAL_PROGRESS++))
}

show_help() {
cat << EOF
Usage: $(basename "$0") [OPTIONS]

Options:
    -h          Show help menu
    -p          Run pingsweep
    -r RANGE    Range of hosts (e.g., 1-200)
    -d          Hostname prefix (e.g., node-)
EOF
}

run_ping_sweep() {
    > pingsweep.log
    base="$1"
    total=0
    totalUp=0
    totalDown=0

    start=$2
    end=$3

    echo "Pinging nodes from range $start-$end..."

    for ((q=start; q<=end; q++)); do
        host="${base}${q}"

        if ping -c 1 -W 1 "$host" &> /dev/null; then
            echo "[ACTIVE]      $host" >> pingsweep.log
            ((totalUp++))
        else
            echo "[NO RESPONSE] $host" >> pingsweep.log
            ((totalDown++))
        fi

        ((total++))
        increment_progress
        progress_bar "$GLOBAL_PROGRESS" "$GLOBAL_TOTAL"
    done

    echo
    upPercent=$(echo "scale=2; ($totalUp/$total)*100" | bc)
    downPercent=$(echo "scale=2; ($totalDown/$total)*100" | bc)

    {
        echo
        echo "======================================================"
        echo "Pingsweep Results:"
        echo "======================================================"
        echo
        echo "Scanned $total_nodes"
        echo "ACTIVE      $totalUp ($upPercent%)"
        echo "NO RESPONSE $totalDown ($downPercent%)"
        echo 
        echo "See pingsweep.log for all captured output."
    } | tee -a pingsweep.log
}

RANGE="1-200"
HOSTNAME_PREFIX="onyxnode"

if [[ $# -eq 0 ]]; then
    echo "Error: No option provided." >&2
    show_help
    exit 1
fi

while getopts ":hpr:d:" opt; do
    case $opt in
        h) show_help exit 0 ;;
        p) RUN=true ;;
        r) RANGE=$OPTARG ;;
        d) HOSTNAME_PREFIX=$OPTARG ;;
        \?) echo "Invalid option: -$OPTARG" >&2; show_help; exit 1 ;;
    esac
done

if [[ "${RUN:-false}" != true ]]; then
    echo "Error: -p is required to run the sweep." >&2
    exit 1
fi

start=${RANGE%-*}
end=${RANGE#*-}

hosts=$(( end - start + 1 ))
init_progress "$hosts"

run_ping_sweep "$HOSTNAME_PREFIX" "$start" "$end"
