#!/bin/bash
# qvm-copy-to-dom0
# Copy a file from an AppVM to dom0
# script has to be run in dom0
# qvm-mycopy to|from <AppVM> <Source in AppVM> <Destination in dom0>

case "$1" in

# Copy to an AppVM
   'from')
      # command line parameters
      AppVM=$2       # must be present
      Source=$3      # must be present
      Destination=$4 # optionally

      # if no Destination given on commandline use ~/QubesIncoming
      if [ -z "$4" ];then mkdir -p ~/QubesIncoming && \
                          Destination=~/QubesIncoming/$(basename $Source); fi

       # copy file from AppVM to dom0
      qvm-run --pass-io $AppVM "cat $Source" > $Destination
      ;;

# Copy from an AppVM
   'to'
      # command line parameters
      Source=$2      # must be present
      AppVM=$3      # must be present
      Destination=$4 # must be present

      # if no Destination given on commandline use /home/user/QubesIncoming
      if [ -z "$4" ];then Destination=/home/user/QubesIncoming; fi

      # copy file from dom0 to AppVM
      qvm-run --pass-io $AppVM "cat $Source" > $Destination
      ;;

   *)
      echo "Error, please use the following Syntax:"
      echo "qvm-mycopy to|from <AppVM> <Source> <Destination>"
      echo
      exit 1
esac

