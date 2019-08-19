#!/bin/bash
# ls-energy.sh - shows estimated battery runtime and current battery drain
# Ouput: 5.7h @ 13.37W/h

ram_sum="("$(xl list | awk '{print $3}' | tail -n +2 | paste -s -d+ -)")/1000"
ram_sum=$(bc <<< "scale=1;$ram_sum")
qubes_sum=$(xl list | grep -v Domain-0 | grep -v dm 2> /dev/null | tail -n +2 | wc -l)
battery_runtime=`upower -d | grep "time to empty" | sed -n '2p' | gawk '{ print $4 }' | cut -c1-4`
discharge_rate=`upower -d | grep energy-rate | sed -n '2p' | gawk '{ print $2 }' | cut -c1-4`

echo $qubes_sum"q|"$ram_sum"G|"$discharge_rate"W/h|"$battery_runtime"h"

