#!/bin/bash
# Show Battery Drain and Battery Runtime
echo "Battery Drain  :" `upower -d | grep "energy-rate"   | head -1 | awk '{ print $2 }'` "W/h"
echo "Battery Runtime:" `upower -d | grep "time to empty" | head -1 | awk '{ print $4 }'` "h"
