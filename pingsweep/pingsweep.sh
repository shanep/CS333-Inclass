#!/bin/bash

base="onyxnode"

for i in {1..200}
    do
        curr="$base$i"
        ping -c 1 $curr
    done