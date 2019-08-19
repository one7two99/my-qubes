#!/bin/bash
# restart sys-net to repair networking after resume
#qvm-run sys-net 'xterm "-hold -e shutdown -h now'

qvm-kill sys-net
qvm-shutdown --quiet --wait --timeout 20 sys-usb
sleep 3
qvm-start sys-net
qvm-start sys-usb
qvm-prefs --set sys-firewall netvm ""
qvm-prefs --set sys-firewall netvm sys-net
#qvm-usb attach sys-net sys-usb:3-4
