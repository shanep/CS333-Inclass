#!/bin/bash

function usage() {
    echo "Usage: $0 -p"
    echo "Option:"
    echo "-p Perform a pingsweep of the nodes"
}

function pingsweep_cmd() {
    nodeFound=0
    nodeNotFound=0
    local base="onyxnode"

    
    echo "Pinging nodes..."
    
    for i in {1..200}; do
        ping -c 1 "${base}${i}" &> /dev/null 
        
        if [ $? -eq 0 ]; then
            echo "${base}${i} is reachable"
            nodeFound=$((nodeFound+1))
        else
            nodeNotFound=$((nodeNotFound+1))
        fi 
    done

    echo "Found $nodeFound nodes reachable."
    echo "Found $nodeNotFound nodes not reachable."
}

function main() {
    while getopts "hp" opt; do
        case "$opt" in
            h) usage ;;          
            p) pingsweep_cmd ;;
            \?)
                echo "Invalid option: -$OPTARG" >&2
                usage
                ;;
        esac
    done
}

main "$@"


