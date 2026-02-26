#!/bin/bash

echo "Running Ping Sweep..."

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Global variables
found=0
total=0
interrupted=false
quiet_mode=false

function usage() {
        echo "Usage: $0 [-h] [-p] [-n count] [-s start] [-b basename] [-t timeout] [-q] [-c] [-j jobs]"
        echo "  -h           Show help message"
        echo "  -p           Perform a ping sweep"
        echo "  -n count     Number of nodes to scan (default: 200)"
        echo "  -s start     Starting node number (default: 1)"
        echo "  -b basename  Base hostname (default: onyxnode)"
        echo "  -t timeout   Ping timeout in seconds (default: 1)"
        echo "  -q           Quiet mode - no progress bar"
        echo "  -c           Export results to CSV format"
        echo "  -j jobs      Number of parallel ping jobs (default: 1, max: 50)"

}

function validate_number() {
    local value=$1
    local name=$2
    if ! [[ "$value" =~ ^[0-9]+$ ]] || [ "$value" -le 0 ]; then
        echo "Error: $name must be a positive integer" >&2
        exit 1
    fi
}

function cleanup() {
    interrupted=true
    printf "\n\n${YELLOW}Scan interrupted by user${NC}\n"
    printf "Partial results: ${found} node(s) found out of ${total} nodes scanned.\n"
    printf "Results saved to pingsweep_results.txt\n"
    exit 0
}

function show_progress() {
    local current=$1
    local total_nodes=$2
    local found_nodes=$3
    local width=50
    local percentage=$((current * 100 / total_nodes))
    local completed=$((width * current / total_nodes))
    
    printf "\r["
    for ((i=0; i<completed; i++)); do printf "${GREEN}#${NC}"; done
    for ((i=completed; i<width; i++)); do printf " "; done
    
    if [ "$current" -eq "$total_nodes" ]; then
        printf "] ${GREEN}%d%%${NC} (%d/%d nodes) | Found: ${GREEN}%d${NC}" "$percentage" "$current" "$total_nodes" "$found_nodes"
    else
        printf "] %d%% (%d/%d nodes) | Found: %d" "$percentage" "$current" "$total_nodes" "$found_nodes"
    fi
}

function pingsweep_cmd() {
    local node_count=${1:-200}
    local start_node=${2:-1}
    local base=${3:-"onyxnode"}
    local timeout=${4:-1}
    local export_csv=${5:-false}
    local parallel_jobs=${6:-1}
    
    # Clear and initialize results file with timestamp
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "=== Ping Sweep Results ===" > pingsweep_results.txt
    echo "Timestamp: $timestamp" >> pingsweep_results.txt
    echo "Base hostname: $base" >> pingsweep_results.txt
    echo "Node range: $start_node to $((start_node + node_count - 1))" >> pingsweep_results.txt
    echo "Timeout: ${timeout}s" >> pingsweep_results.txt
    echo "Parallel jobs: $parallel_jobs" >> pingsweep_results.txt
    echo "=========================" >> pingsweep_results.txt
    echo "" >> pingsweep_results.txt
    
    # Setup CSV if requested
    if [ "$export_csv" = true ]; then
        echo "Hostname,IP_Address,Status,Timestamp" > pingsweep_results.csv
    fi
    
    found=0
    total=$node_count
    local end_node=$((start_node + node_count - 1))
    
    if [ "$quiet_mode" = false ]; then
        echo "Starting ping sweep of $total nodes (${base}${start_node} to ${base}${end_node})..."
    fi
    
    # Setup signal trap for CTRL+C
    trap cleanup SIGINT SIGTERM
    
    if [ "$parallel_jobs" -gt 1 ]; then
        # Parallel pinging
        local temp_dir=$(mktemp -d)
        local current=0
        
        for ((i=start_node; i<=end_node; i++)); do
            while [ $(jobs -r | wc -l) -ge "$parallel_jobs" ]; do
                sleep 0.1
            done
            
            (
                local node_name="${base}${i}"
                if ping -c 1 -W "$timeout" "$node_name" > "$temp_dir/ping_$i.tmp" 2>&1; then
                    echo "REACHABLE|$node_name" > "$temp_dir/result_$i.txt"
                    # Extract IP if possible
                    local ip=$(grep -oP '\d+\.\d+\.\d+\.\d+' "$temp_dir/ping_$i.tmp" | head -1)
                    echo "$ip" > "$temp_dir/ip_$i.txt"
                else
                    echo "UNREACHABLE|$node_name" > "$temp_dir/result_$i.txt"
                fi
            ) &
            
            current=$((current + 1))
            if [ "$quiet_mode" = false ]; then
                # Count completed results
                local completed=$(ls "$temp_dir"/result_*.txt 2>/dev/null | wc -l)
                local temp_found=$(grep -l "REACHABLE" "$temp_dir"/result_*.txt 2>/dev/null | wc -l)
                show_progress "$completed" "$total" "$temp_found"
            fi
        done
        
        # Wait for all background jobs to complete
        wait
        
        # Process results
        for ((i=start_node; i<=end_node; i++)); do
            local result_file="$temp_dir/result_$i.txt"
            if [ -f "$result_file" ]; then
                local result=$(cat "$result_file")
                local status=$(echo "$result" | cut -d'|' -f1)
                local node_name=$(echo "$result" | cut -d'|' -f2)
                local ip=$(cat "$temp_dir/ip_$i.txt" 2>/dev/null || echo "N/A")
                local scan_time=$(date '+%Y-%m-%d %H:%M:%S')
                
                if [ "$status" = "REACHABLE" ]; then
                    echo "Node ${node_name} is reachable. (IP: $ip)" >> pingsweep_results.txt
                    found=$((found + 1))
                    if [ "$export_csv" = true ]; then
                        echo "$node_name,$ip,reachable,$scan_time" >> pingsweep_results.csv
                    fi
                else
                    echo "Node ${node_name} is NOT reachable" >> pingsweep_results.txt
                    if [ "$export_csv" = true ]; then
                        echo "$node_name,N/A,unreachable,$scan_time" >> pingsweep_results.csv
                    fi
                fi
            fi
        done
        
        # Cleanup temp directory
        rm -rf "$temp_dir"
        
        if [ "$quiet_mode" = false ]; then
            show_progress "$total" "$total" "$found"
        fi
    else
        # Sequential pinging
        local current=0
        for ((i=start_node; i<=end_node; i++)); do
            current=$((current + 1))
            
            if [ "$quiet_mode" = false ]; then
                show_progress "$current" "$total" "$found"
            fi
            
            local node_name="${base}${i}"
            local scan_time=$(date '+%Y-%m-%d %H:%M:%S')
            
            if ping -c 1 -W "$timeout" "$node_name" > /tmp/ping_tmp.txt 2>&1; then
                local ip=$(grep -oP '\d+\.\d+\.\d+\.\d+' /tmp/ping_tmp.txt | head -1)
                echo "Node ${node_name} is reachable. (IP: $ip)" >> pingsweep_results.txt
                found=$((found + 1))
                if [ "$export_csv" = true ]; then
                    echo "$node_name,$ip,reachable,$scan_time" >> pingsweep_results.csv
                fi
            else
                echo "Node ${node_name} is NOT reachable" >> pingsweep_results.txt
                if [ "$export_csv" = true ]; then
                    echo "$node_name,N/A,unreachable,$scan_time" >> pingsweep_results.csv
                fi
            fi
        done
    fi
    
    printf "\n"
    echo ""
    echo "=== Summary ===" | tee -a pingsweep_results.txt
    echo "Pingsweep complete: ${found} node(s) found out of ${total} nodes." | tee -a pingsweep_results.txt
    echo "" | tee -a pingsweep_results.txt
    
    # List reachable nodes
    echo "Reachable nodes:" | tee -a pingsweep_results.txt
    grep "is reachable" pingsweep_results.txt | sed 's/Node \(.*\) is reachable.*/  - \1/' | tee -a pingsweep_results.txt
    
    echo ""
    echo "Results saved to pingsweep_results.txt"
    if [ "$export_csv" = true ]; then
        echo "CSV export saved to pingsweep_results.csv"
    fi
}


function main() {
        local node_count=200
        local start_node=1
        local base_name="onyxnode"
        local timeout=1
        local export_csv=false
        local parallel_jobs=1
        local run_sweep=false
        
        while getopts ":hpn:s:b:t:qcj:" opt; do
                case ${opt} in
                        h) usage; exit 0 ;;
                        p) run_sweep=true ;;
                        n) node_count=$OPTARG ;;
                        s) start_node=$OPTARG ;;
                        b) base_name=$OPTARG ;;
                        t) timeout=$OPTARG ;;
                        q) quiet_mode=true ;;
                        c) export_csv=true ;;
                        j) parallel_jobs=$OPTARG ;;
                        \?) echo "Invalid option: -$OPTARG" >&2; usage; exit 1 ;;
                        :) echo "Option -$OPTARG requires an argument" >&2; usage; exit 1 ;;
                esac
        done
        
        # Validate inputs
        if [ "$run_sweep" = true ]; then
            validate_number "$node_count" "Node count"
            validate_number "$start_node" "Start node"
            validate_number "$timeout" "Timeout"
            validate_number "$parallel_jobs" "Parallel jobs"
            
            # Limit parallel jobs to reasonable maximum
            if [ "$parallel_jobs" -gt 50 ]; then
                echo "Warning: Limiting parallel jobs to 50 (requested: $parallel_jobs)" >&2
                parallel_jobs=50
            fi
            
            pingsweep_cmd "$node_count" "$start_node" "$base_name" "$timeout" "$export_csv" "$parallel_jobs"
        fi
}

if [ $# -eq 0 ]; then
        usage
        exit 1
else
        main "$@"
fi
