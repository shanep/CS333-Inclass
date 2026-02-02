# ...existing code...
#!/bin/bash
# Ping sweep the Lab

base="onyxnode"
count=30
logfile="ping.log"
perform=0

usage() {
cat <<EOF
Usage: $(basename "$0") [-h] [-p][-n count] [-l logfile]

Options:
  -h        Show this help and exit
  -p        Perform the ping sweep (default: dry-run; without -p the script only prints actions)
  -n count  Number of hosts to ping (default: $count)
  -l file   Log file (default: $logfile)
EOF
}

while getopts "hpb:n:l:" opt; do
  case $opt in
    h) usage; exit 0 ;;
    p) perform=1 ;;
    n) count="$OPTARG" ;;
    l) logfile="$OPTARG" ;;
    *) usage; exit 1 ;;
  esac
done

# validate count
if ! [[ "$count" =~ ^[0-9]+$ ]] || [ "$count" -le 0 ]; then
  echo "Invalid count: $count" >&2
  exit 1
fi

if [ "$perform" -eq 1 ]; then
  : > "$logfile"
  echo "Performing ping sweep: base=$base count=$count -> logging to $logfile"
else
  echo "Dry-run (no pings). Use -p to perform the sweep."
fi

for q in $(seq 1 "$count"); do
  curr="${base}${q}"
  if [ "$perform" -eq 1 ]; then
    ping -c 1 "$curr" >> "$logfile" 2>&1
  else
    echo "DRY-RUN: ping -c 1 $curr"
  fi
done
# ...existing code...
