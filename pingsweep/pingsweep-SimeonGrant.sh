#!/bin/bash
# Ping sweep the Lab

#help function
help_func() {
        echo "Pingsweep.sh command Help"
        echo ""

        echo "[-c ]" "ping all nodes in local network c times"
        echo "[-p ] ping" "Performs pingsweep of all nodes on the network."
        echo "[-h ] help" "brings up man page for pingsweep.sh"
        echo ""

        echo "Usage"
        echo " ./pingsweep.sh [command ...]"
        echo "" 

}
<<OldP
#p function
pingsweep_func() {
        base="onyxnode"
        for q in {1..200}
        do
                curr=$base$q
                ping -c 1 $curr >> ping.log 
        done
}
OldP
#p flag function.
pingsweep_func() {
        rm ping.log
        local base="onyxnode"
        local found=0
        local total=0
        local totalSearch=200
	for (( q=1; q<=$totalSearch; q++))
        do
                echo "$q out of $totalSearch"
                curr=$base$q
                ping -c 1 -W 1 ${curr} >> ping.log

                if [ $? -eq 0 ]; then
                        echo "Node ${curr} is reachable"
                        found=$((found + 1))
                else
                        echo "Node ${curr} is not reachable" | tee -a ping.log
                fi
                total=$((total + 1))

        done

        echo "Found: $found"
        echo "Total: $total"
}



#main function
main() {
        for cmd in "$@"; do
                case "$cmd" in
                        ping|-p) pingsweep_func;;
                        help|-h) help_func;;
                        *)
                                echo "Unknown command: $cmd"
                                help_func
                                exit 1;;
                        esac
                done
}
main "$@"