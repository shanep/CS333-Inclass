#!/bin/bash
# Ping sweep the Lab

# Configuration
base="onyxnode"
logfile="ping.log"

sanity_check() {
    echo "--- Performing Sanity Check (Ping 8.8.8.8) ---"
    if ping -c 1 -W 2 8.8.8.8 &> /dev/null; then
        echo "Sanity check PASSED: Internet/Network is reachable."
    else
        echo "Sanity check FAILED: Cannot reach 8.8.8.8."
        echo "Please check your network connection."
    fi
    echo "----------------------------------------------"
    echo ""
}

help_func(){
    echo "Available Commands:"
    echo "  ping, p      Perform a new ping sweep of the lab"
    echo "  help, h      Display this help message"
    echo "  exit, e, x   Exit the program"
    echo ""
}

perform_sweep() {
    echo "Starting ping sweep for ${base}1 through ${base}200..."
    
    # Empty the log file at start of new sweep
    > "$logfile"

    hits=0
    scanned=0
    for q in {1..200}
    do
        curr="$base$q"
        
        # -c 1: Count 1 packet
        # -W 1: Wait max 1 second for response
        scanned=$((scanned + 1))
        if ping -c 1 -W 1 "$curr" &> /dev/null; then
            echo "$curr is UP"
            echo "$curr" >> "$logfile"
            hits=$((hits + 1))
        else
            echo "$curr is DOWN"
        fi
    done

    echo ""
    echo "Found $hits hosts UP."
    echo "Scanned $scanned nodes." 
    unresponsive=$((scanned - hits))
    echo "Unresponsive machines: $unresponsive"
    echo ""
    echo "Sweep complete. Results saved to $logfile"
    echo ""
}

main() {
    # 1. Run Sanity Check immediately on startup
    sanity_check

    # 2. Show help once so user knows what to do
    help_func

    # 3. Enter infinite loop for interactive mode
    while true; do
        read -p "pingsweep> " input_cmd

        case "$input_cmd" in
            ping|p) 
                perform_sweep 
                ;;
            help|h) 
                help_func 
                ;;
            exit|e|x)
                echo "Exiting..."
                exit 0
                ;;
            "") 
                # Do nothing if user just hits enter
                ;;
            *)
                echo "Unknown command: $input_cmd"
                echo "Type 'h' for help."
                ;;
        esac
    done
}

main