sys-usb.autoshutdown
====================

based on an idea from a member in the Qubes Telegram group in 12/22.
The idea is to shutdown sys-usb when the last usb device has been detached from a qube.
Because I didn't came up with a realtime solution we're using a simpler approach:

1. setup cron in dom0 to run a script /home/user/bin/sys-usb.autoshutdown.sh
2. this script will check if usb devices are attached to qubes
3. if not the script will shutdown sys-usb and create a few lines in system log

setup cron
----------

```
[user@dom0 ~]$ crontab -e
# Add the following line to the crontab and save with <Escape> + w + q
*/5 * * * * /home/user/bin/sys-usb.autoshutdown.sh >/dev/null 2>&1

[user@dom0 ~]$ systemctl restart crond
Not sure if this is really needed.
```

create script
-------------
create the following script in /home/user/bin/sys-usb.autoshutdown.sh
(You can of course also store it somewhere else, as long as the path to this script is setup correctly in the crontab file.

```
#!/bin/bash
#  sys-usb-autoshutdown.sh
#  v0.1 12/12/22
#  https://github.com/one7two99/
#  check if a device is attached via qvm-usb to another qube
#  if not -> shutdown sys-usb qube

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
```
Important: make the script executable
```
chmod +x /home/user/bin/sys-usb.autoshutdown.sh
```
