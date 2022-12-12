#!/bin/bash
### Name: attach-wan.sh
### Purpose: Attach USB-WAN-Card to sys-net by name not by ID as the ID seems to change from time to time
### Author: one7two99
### Date: 05 Nov 2022

# name of usb device
USBWanCard=FIBOCOM_L831-EAU-00_004999010640000
# name of USB-qube
usbvm=sys-usb
# name of NetVM
netvm=sys-net
# Launch USVB qube if not running
qvm-start --skip-if-running $usbvm
# Attach WAN-Card to NetVM by ID
qvm-usb attach $netvm `qvm-usb | grep $USBWanCard | gawk '{ print $1 }'`
