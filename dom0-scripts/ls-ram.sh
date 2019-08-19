#!/bin/bash
ram_sum="("$(xl list | awk '{print $3}' | tail -n +2 | paste -s -d+ -)")/1000"
ram_sum=$(bc <<< "scale=1;$ram_sum")
qubes_sum=$(xl list 2> /dev/null | tail -n +2 | wc -l)
qubes_sum=$(bc <<< "($qubes_sum-1)/2")
echo $qubes_sum"Q|"$ram_sum"G" 
