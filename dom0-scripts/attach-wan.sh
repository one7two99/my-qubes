#!/bin/bash
# Attach USB-WAN-Card to sys-net
USBWanCard=H5321
usbvm=sys-usb
qvm-start --skip-if-running sys-usb
qvm-usb attach sys-net `qvm-usb | grep H5321 | gawk '{ print $1 }'`

