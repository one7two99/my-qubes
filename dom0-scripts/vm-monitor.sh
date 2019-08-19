#!/bin/bash
# vm-monitor

#!/bin/bash
# name   : vm-monitor.sh
# usage  : script to show names of running VMs and summary of RAM and CPU Cores
#          Run this script via 'watch -t -n 10 ./vm-monitor.sh'
# author : one7two99@gmail.com
# version: 0.1
# date   : 19/06/18
#
echo
echo "-==[ Running AppVMs ]==-"
xl list | awk '{print $1}' | grep -v Domain-0 | grep -v dm | tail -n +2 
echo "------------------------"
printf "CPU total [Cores]: " && echo "scale=1;(`xl list | awk '{print $4}' | tail -n +2 | paste -s -d+ -`)" | bc
printf "RAM total [ GiB ]: " && echo "scale=1;(`xl list | awk '{print $3}' | tail -n +2 | paste -s -d+ -`)/1000" | bc 
echo
