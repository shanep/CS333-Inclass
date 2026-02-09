#!/bin/bash
#
# Pingsweeper - Auto-Detect Network Sweeper
#

set -o pipefail

# --- Configuration Defaults ---
LOG_FILE="scan_results.log"
TIMEOUT=1
PING_COUNT=1      
MAX_JOBS=50       # Safety Semaphore
VERBOSE=false

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_banner() {
    clear
    echo -e "${BLUE}=======================================${NC}"
    echo -e "${BLUE}       ONYXNODE UNIVERSAL              ${NC}"
    echo -e "${BLUE}=======================================${NC}"
}

usage() {
    print_banner
    echo -e "\nUsage: $0 <target_base> [options]"
    echo -e "\nAuto-Detect Examples:"
    echo -e "  $0 192.168.1            # Detects IP Mode (Scans 192.168.1.1...)"
    echo -e "  $0 web-server           # Detects Hostname Mode (Scans web-server01...)"
    echo -e ""
    echo -e "Options:"
    echo -e "  -c <num>    Pings per host (default: 1)"
    echo -e "  -r <start>  Start range (default: 1)"
    echo -e "  -e <end>    End range (default: 254)"
    echo -e "  -t <sec>    Timeout seconds (default: 1)"
    echo -e "  -o <file>   Output log file"
    echo -e "  -v          Verbose (show DOWN hosts)"
    echo -e "  -H          Force Hostname mode (override auto-detect)"
    echo -e "  -I          Force IP mode (override auto-detect)"
    echo ""
    exit 1
}

# --- 1. Parse Options (Getopts) ---
# We process flags first.
MODE="AUTO"
START_RANGE=1
END_RANGE=254

# Use 'shift' later to handle the positional target argument
while getopts "HIc:r:e:t:o:vh" opt; do
  case $opt in
    H) MODE="HOSTNAME" ;;
    I) MODE="IP" ;;
    c) PING_COUNT="$OPTARG" ;;
    r) START_RANGE="$OPTARG" ;;
    e) END_RANGE="$OPTARG" ;;
    t) TIMEOUT="$OPTARG" ;;
    o) LOG_FILE="$OPTARG" ;;
    v) VERBOSE=true ;;
    h) usage ;;
    *) usage ;;
  esac
done
shift $((OPTIND -1))

# --- 2. Smart Auto-Detect Logic ---
# The first remaining argument is our Target Base
TARGET_BASE="$1"

if [ -z "$TARGET_BASE" ]; then
    echo -e "${RED}Error: No target specified.${NC}"
    usage
fi

# If mode is still AUTO, we detect based on Regex
if [ "$MODE" == "AUTO" ]; then
    # Regex: Matches patterns like "192.168.1" or "10.0.0"
    if [[ "$TARGET_BASE" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        MODE="IP"
    elif [[ "$TARGET_BASE" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.$ ]]; then
        # Handles user inputting trailing dot "192.168.1."
        MODE="IP"
        TARGET_BASE=${TARGET_BASE%?} # Remove trailing dot
    else
        MODE="HOSTNAME"
    fi
fi

# --- 3. OS Detection & Ping Setup ---
OS_NAME=$(uname)
if [ "$OS_NAME" == "Darwin" ]; then
    PING_CMD="ping -c $PING_COUNT -t $TIMEOUT"
else
    PING_CMD="ping -c $PING_COUNT -W $TIMEOUT"
fi

# --- Helper: DNS Resolution ---
resolve_target() {
    local target=$1
    local type=$2 
    
    if [ "$type" == "host" ]; then
        # Host -> IP
        if [ "$OS_NAME" == "Darwin" ]; then
            dscacheutil -q host -a name "$target" | grep ip_address | awk '{print $2}' | head -n1
        else
            getent hosts "$target" | awk '{print $1}' | head -n1
        fi
    else
        # IP -> Host
        host "$target" 2>/dev/null | awk '/domain name pointer/ {print $NF}' | sed 's/\.$//' | head -n1
    fi
}

perform_sweep() {
    local temp_file
    temp_file=$(mktemp)
    
    echo "--- Scan started at $(date) ---" > "$LOG_FILE"
    echo "--- Params: Count=$PING_COUNT, Timeout=$TIMEOUT ---" >> "$LOG_FILE"
    print_banner
    echo -e "Target Base: ${YELLOW}$TARGET_BASE${NC}"
    echo -e "Detected Mode: ${YELLOW}$MODE${NC}"
    echo -e "Scanning Range: $START_RANGE - $END_RANGE"
    
    # Padding Logic for Hostnames
    if [ "$MODE" == "HOSTNAME" ]; then
        PAD_LEN=${#START_RANGE}
    fi

    for (( i=START_RANGE; i<=END_RANGE; i++ )); do
        (
            # Construct Target
            if [ "$MODE" == "HOSTNAME" ]; then
                printf -v suffix "%0${PAD_LEN}d" "$i"
                target="${TARGET_BASE}${suffix}"
            else
                target="${TARGET_BASE}.${i}"
            fi
            
            # Ping
            if $PING_CMD "$target" &> /dev/null; then
                
                # Bi-directional Resolution ("Do Both")
                if [ "$MODE" == "HOSTNAME" ]; then
                    extra_info=$(resolve_target "$target" "host")
                else
                    extra_info=$(resolve_target "$target" "ip")
                fi
                
                if [ -n "$extra_info" ]; then
                     echo "UP $target ($extra_info)" >> "$temp_file"
                else
                     echo "UP $target" >> "$temp_file"
                fi
            else
                echo "DOWN $target" >> "$temp_file"
            fi
        ) & 
        
        # Semaphore
        while [ $(jobs -p | wc -l) -ge $MAX_JOBS ]; do
            sleep 0.1
        done
    done

    wait

    # Display
    local count_up
    count_up=$(grep -c "^UP" "$temp_file")
    
    echo -e "\n${BLUE}--- Active Nodes ---${NC}"
    
    if [ -s "$temp_file" ]; then
        sort -V "$temp_file" | while read -r line; do
            status=$(echo "$line" | awk '{print $1}')
            rest=$(echo "$line" | cut -d' ' -f2-)
            
            if [ "$status" == "UP" ]; then
                echo -e "${GREEN}[UP]${NC}   $rest"
                echo "[$(date "+%H:%M:%S")] [UP] $rest" >> "$LOG_FILE"
            elif [ "$VERBOSE" = true ]; then
                echo -e "${RED}[DOWN]${NC} $rest"
            fi
        done
    else
        echo -e "${RED}No active hosts found.${NC}"
    fi

    echo -e "\n${BLUE}Scan Complete.${NC}"
    echo -e "Total UP: ${GREEN}$count_up${NC}"
    rm -f "$temp_file"
}

perform_sweep