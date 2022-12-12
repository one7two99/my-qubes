#!/bin/bash
#  sys-usb-autoshutdown.sh
#  v0.1
#  check if a device is attached via qvm-usb to another qube
#  if not -> shutdown sys-usb qube
#  Needs to be triggered via a cronjob, ex. every 5 minutes

# Variables
usbqube=sys-usb

# store name of qube which has a usb device attached in $UsbAttached
UsbAttached=`qvm-usb | gawk '{ print $3 }' | sort | tail -1`

# In case $UsbAttached is empty it means no usb device is attached
if [ -z "$UsbAttached" ]; then
   # Send a line to log (you can check the log via journalctl -f)
   logger -t $0 "No USB device attached. Trying to shutdown $usbqube"
   # Shutdown your usbqube
   qvm-shutdown --wait $usbqube
   # Send line to log
   logger -t $0 "Shutdown $usbqube completed!"
fi

