#!/bin/bash
#
# pingsweep-ianWall.sh
#
# Description:
# Simple implementation of pingsweep, includes all required options and features:
# - Displays a usage command
# - Parses options using getopts
# - Validates that a mode was selected and that -r and -e were passed if -n is used
# - Works on macOS and Linux
# - Scans all addresses based on IP, displays a hostname if possible, and runs them using background subshells
# - Auto detects the machine's local IP if -d is passed
# - Sweeps based on a hostname and range if -n, -r, and -e are used
# - Properly formats output to show which hosts are online
#
# Challenges:
# - I have minimal experience in bash which makes writing code take longer.
# - This was written in vim so any typos were hard to detect until testing.
# - Running pings in parallel was complicated and difficult to understand.
# 
# Author: Ian Wall
# Date: 2026-02-11

IP_PREFIX=""
HOST_PREFIX=""
RANGE_START=""
RANGE_END=""
TIMEOUT=1
AUTO_DETECT=false

function ip_sweep()
{
	local prefix="$1"
	local tmpdir
	tmpdir=$(mktemp -d)

	echo "Scanning network: ${prefix}.1 - ${prefix}.254"
	echo "Timeout: ${TIMEOUT}s"
	echo

	for i in {1..254}; do
		(
			ip="${prefix}.${i}"
			if ping_host "$ip"; then
				hostname=$(getent hosts "$ip" 2>/dev/null | awk '{print $2}')
				if [[ -z "$hostname" ]]; then
					echo "$ip" >> "$tmpdir/up.txt"
				else
					echo "$ip ($hostname)" >> "$tmpdir/up.txt"
				fi
			fi
		) &
	done

	wait

	echo "---- Hosts Up ----"
	if [[ -f "$tmpdir/up.txt" ]]; then
		sort -V "$tmpdir/up.txt"
	else
		echo "No hosts responded :("
	fi
	rm -rf "$tmpdir"
}

function auto_detect_prefix()
{
	local os
	local ip
	os=$(uname)
	
	if [[ "$os" == "Darwin" ]]; then
		ip=$(ipconfig getifaddr en0 2>/dev/null)

		if [[ -z "$ip" ]]; then
			ip=$(ipconfig getifaddr en1 2>/dev/null)
		fi
	else
		ip=$(hostname -I | awk '{print $1}')
	fi

	if [[ -z "$ip" ]]; then
		echo "Error: Could not auto-detect local IP address"
		exit 1
	fi

	IP_PREFIX=$(echo "$ip" | cut -d. -f1-3)
}

function ping_host()
{
	local host="$1"
	local os
	os=$(uname)

	if [[ "$os" == "Darwin" ]]; then
		ping -c 1 -t "$TIMEOUT" "$host" > /dev/null 2>&1
	else
		ping -c 1 -W "$TIMEOUT" "$host" > /dev/null 2>&1
	fi
	return $?
}

function usage()
{
	echo "Usage: $0 [options]"
    	echo
    	echo "Options:"
    	echo "-i <prefix>   Network prefix (e.g., 192.168.1)"
    	echo "-d            Auto-detect network prefix"
    	echo "-n <prefix>   Hostname prefix (e.g., web-server-)"
    	echo "-r <start>    Range start (hostname mode)"
    	echo "-e <end>      Range end (hostname mode)"
    	echo "-t <seconds>  Timeout (default 1s)"
    	echo "-h            Help"
    	echo
}

function validate()
{
	if [[ -z "$IP_PREFIX" && "$AUTO_DETECT" != true && -z "$HOST_PREFIX" ]]; then
		echo "Error: you must select a mode (-i, -d, or -n)"
		usage
		exit 1
	fi

	if [[ -n "$HOST_PREFIX" ]]; then
		if [[ -z "$RANGE_START" || -z "$RANGE_END" ]]; then
			echo "Error: Hostname mode (-n) requires both -r and -e"
			usage
			exit 1
		fi
	fi
}

function host_sweep() 
{
	local prefix="$1"
	local start="$2"
	local end="$3"

	local tmpdir
	tmpdir=$(mktemp -d)
	local width=0

	printf "%s\n" "----------------------------"
	printf "Scanning %s%0*d - %s%0*d ...\n" "$prefix" "$width" "$start" "$prefix" "$width" "$end"
	printf "%s\n" "----------------------------"

	if [[ "$start" =~ ^0 ]]; then
		width=${#start}
	fi


	for ((i=start; i<=end; i++)); do
		(
			if [[ "$width" -gt 0 ]]; then
				num=$(printf "%0*d" "$width" "$i")
			else
				num="$i"
			fi

			host="${prefix}${num}"

			if ping_host "$host"; then
				ip=$(getent hosts "$host" 2>/dev/null | awk '{print $1}')

				if [[ -z "$ip" ]]; then
					echo "[UP] $host" >> "$tmpdir/up.txt"
				else
					echo "[UP] $host ($ip)" >> "$tmpdir/up.txt"
				fi
			else
				echo "$host" >> "$tmpdir/down.txt"
			fi
		) &
	done

	wait

	if [[ -f "$tmpdir/up.txt" ]]; then
		sort "$tmpdir/up.txt"
		FOUND=$(wc -l < "$tmpdir/up.txt")
	else
		FOUND=0
	fi
	
	if [[ -f "$tmpdir/down.txt" ]]; then
		NOT_FOUND=$(wc -l < "$tmpdir/down.txt")
	else
		NOT_FOUND=0
	fi

	printf "%s\n" "----------------------------"
    	echo "Nodes found: $FOUND"
    	echo "Nodes not found: $NOT_FOUND"
    	echo "Scan complete."

	rm -rf "$tmpdir"
}

function main() {
	TIMEOUT=1
	AUTO_DETECT=false
	while getopts ":i:dn:r:e:t:h" opt; do
		case ${opt} in 
			i) IP_PREFIX="$OPTARG" ;;
			d) AUTO_DETECT=true ;;
			n) HOST_PREFIX="$OPTARG" ;;
			r) RANGE_START="$OPTARG" ;;
			e) RANGE_END="$OPTARG" ;;
			t) TIMEOUT="$OPTARG" ;;
			h) usage; exit 0 ;;
			?) 
            			echo "Invalid option: -$OPTARG" >&2
            			usage
            			exit 1
            			;;
        		:)
            			echo "Option -$OPTARG requires an argument." >&2
            			usage
            			exit 1
            			;;
		esac
	done
	shift $((OPTIND -1))
}

if [ $# -eq 0 ]; then
	usage
	exit 0
fi

main "$@"
validate

if [[ "$AUTO_DETECT" == true ]]; then
	auto_detect_prefix
	ip_sweep "$IP_PREFIX"

elif [[ -n "$IP_PREFIX" ]]; then
	ip_sweep "$IP_PREFIX"

elif [[ -n "$HOST_PREFIX" ]]; then
	host_sweep "$HOST_PREFIX" "$RANGE_START" "$RANGE_END"

else
	echo "No valid mode selected"
	usage
	exit 1
fi
