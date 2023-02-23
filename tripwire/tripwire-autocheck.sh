
#!/bin/bash
# Author     : one7two99
# Version    : 0.1.20230223
# Link       : https://github.com/one7two99/my-qubes/new/master/tripwire
# Description: script to run tripwire check after login
#              and present a ppop-up notification with the result
# Location   : /home/user/tripwire-autocheck.sh

# Define icons to be used for PopUp-notifications
StartIcon=/usr/share/icons/gnome/48x48/status/security-medium.png
OkIcon=/usr/share/icons/gnome/48x48/status/dialog-information.png
WarningIcon=/usr/share/icons/gnome/48x48/status/dialog-warning.png
ErrorIcon=/usr/share/icons/gnome/48x48/status/dialog-error.png 

# Location of tripwire logfile which will log the output of this script
TripwireLog=/home/user/tripwire.log
# Geometry for the xterm window to present the log, if Exit Code is not 0
XtermGeometry=90x50

# Take a short break as this script is run after login
sleep 5

# run tripwire check
notify-send -u normal -i $StartIcon "tripwire" "Auto-check after login in progress."
sudo tripwire --check > $TripwireLog

# Save tripwire exitcode
TripwireExitCode=$?

# Make the log readable for the dom0-user
sudo chmod 666 $TripwireLog

# check exit code of the tripwire run
case $TripwireExitCode in
  0)
    # No errors, no violations
    notify-send -u normal -i $OkIcon "tripwire" "Exit code [$TripwireExitCode]: Check completed - all good.."
    exit 0
    ;;
  3)
    # Files modified
    notify-send -u normal -i $WarningIcon "tripwire" "Exit code [$TripwireExitCode]: Files modified!"
    xterm -title "Please review tripwire log" -geometry $XtermGeometry -e "less $TripwireLog"
    exit 3
    ;;
  5)
    # Files added and modified
    notify-send -u normal -i $WarningIcon "tripwire" "Exit code [$TripwireExitCode]: Files added and modified!"
    xterm -title "Please review tripwire log" -geometry $XtermGeometry -e "less $TripwireLog"
    exit 5
    ;;
  6)
    # Files removed and modified
    notify-send -u normal -i $WarningIcon "tripwire" "Exit code [$TripwireExitCode]: Files removed and modified!"
    xterm -title "Please review tripwire log" -geometry $XtermGeometry -e "less $TripwireLog"
    exit 6
    ;;
  7)
    # Files added, removed and modified
    notify-send -u normal -i $WarningIcon "tripwire" "Exit code [$TripwireExitCode]: Files added, removed and modified!"
    xterm -title "Please review tripwire log" -geometry $XtermGeometry -e "less $TripwireLog"
    exit 7
    ;;
  8)
    # Configuration error (ie. tw.pol or tw.cfg missing)
    notify-send -u normal -i $ErrorIcon "tripwire" "Exit code [$TripwireExitCode]: Configuration error!"
    xterm -title "Please review tripwire log" -geometry $XtermGeometry -e "less $TripwireLog"
    exit 8
    ;;
  *)
    # Something else happened
    notify-send -u normal -i $ErrorIcon "tripwire" "Exit code [$TripwireExitCode]: Unknown status, review $TripwireLog"
    xterm -title "Please review tripwire log" -geometry $XtermGeometry -e "less $TripwireLog"
    exit 9
    ;;
esac
