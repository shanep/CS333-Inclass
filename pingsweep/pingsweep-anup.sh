#!/bin/bash
# Ping sweep the Lab

base="onyxnode"
LOG="ping.log"

show_help() {
  echo "Usage: $0 -p"
  echo
  echo "Options:"
  echo "  -p    Run ping sweep on ${base}1–${base}200"
  echo "  -h    Show this help menu"
}

pingsweep(){

  found=0
  missing=0

  > $LOG

  for q in {1..200}
  do
    curr="$base$q"

    ping -c 1 $curr >> $LOG 2>&1

    if [ $? -eq 0 ]; then
      echo "$curr responded"
      ((found++))
    else
      echo "$curr no response"
      ((missing++))
    fi
  done

  echo
  echo "Sweep Complete"
  echo "Found: $found"
  echo "Missing: $missing"
}

case "$1" in
  -p)
    pingsweep
    ;;
  -h)
    show_help
    ;;
  *)
    show_help
    ;;
esac