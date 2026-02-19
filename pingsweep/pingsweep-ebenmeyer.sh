#!/usr/bin/env bash

usage() {
cat <<'EOF'
Usage:
  ./pingsweep.sh -p
  ./pingsweep.sh -h

Options:
  -p    Run ping sweep on onyxnode hosts
  -h    Show this help menu
EOF
}

pingsweep_cmd() {
  local base="onyxnode"   
  local count=200
  local logfile="ping.log"
  local found=0
  local missing=0

  echo "Starting ping sweep..." | tee -a "$logfile"

  for i in $(seq 1 "$count"); do
    local node="${base}${i}"

    # Send output to log AND capture it
    local output
    output="$(ping -c 1 -W 1 "$node" 2>&1 | tee -a "$logfile")"

    # Parse success/failure using regex
    if echo "$output" | grep -qE 'bytes from|1 received|1 packets received'; then
      echo "Node $node is reachable." | tee -a "$logfile"
      found=$((found + 1))
    else
      echo "Node $node is not reachable." | tee -a "$logfile"
      missing=$((missing + 1))
    fi
  done

  echo "Ping sweep complete." | tee -a "$logfile"
  echo "Found: $found" | tee -a "$logfile"
  echo "Missing: $missing" | tee -a "$logfile"
}

main() {
  while getopts ":hp" opt; do
    case "$opt" in
      h)
        usage
        exit 0
        ;;
      p)
        pingsweep_cmd
        exit 0
        ;;
      \?)
        echo "Invalid option: -$OPTARG" >&2
        usage
        exit 1
        ;;
    esac
  done

  # If ran with no flags, show help
  usage
  exit 1
}

# Script entry point
if [ $# -eq 0 ]; then
  usage
  exit 1
else
  main "$@"
fi
