#!/bin/bash
# name   : qvm-show-swap-sh
# version: 0.2
# date   : 15.12.2018
# author : one7two99 

# define allowed maximum swap usage in Mb on the command line
# if more swap space is used in an AppVM a warning notification will pop-up
# check if a command line argument is set, if not set maxswap to 0
if [ -z "$1" ]
   then
      maxswap=0
   else
      maxswap=$1
fi
# get a list of all running AppVms (except dom0)
for i in `qvm-ls --running -O name --raw-data | grep -v dom0`;
do
  # get swap usage in the AppVM
  swapused=`qvm-run --pass-io $i "free -m" | tail -n+3 | gawk '{print $3}'`;
  # Check if swap usage is > than maxswap
  if [ "$swapused" -gt "$maxswap" ]; then
    # create a PopUp-notification
    notify-send --urgency normal --icon dialog-warning --expire-time=5000 "$i" ".. is using $swapused Mb swap";
  fi;
done

