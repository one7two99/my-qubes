#!/bin/bash
# Show Battery Drain and Battery Runtime
echo BAT: `upower -d | grep "percentage"   | head -1 | awk '{ print $2 }'`"|"\
`upower -d | grep "time to empty" | head -1 | awk '{ print $4 }'`"h|"\
`upower -d | grep "energy-rate"   | head -1 | awk '{ print $2 }' | head -c -3`"W"
