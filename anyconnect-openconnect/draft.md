Install packages to use openconnect:
```
sudo install ocproxy pass zenity openconnect
```
- ocproxy = can be used to launch openconnect without using sudo or changing /etc/sudoers
- pass = used to encrypt the VPN password
- zenity = used to get nice notifications

Script to autoconnect via openconnect
store this script at /home/JOHNDOE/openconnect/openconnect.sh
```
#!/bin/bash
VpnUsername=JOHNDOE
VpnServer=VPN.DOEINC.COM
VpnScript=~/openconnect/openconnect.script
echo $(pass show DOEINC/JOHNDOE) | sudo openconnect \
        --user=$VpnUsername \
        --authgroup=DOEINC \
        --passwd-on-stdin  \
        --servercert pin-sha256:eXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX \
        --base-mtu=1450 \
        --script=$VpnScript \
        $VpnServer
```

to use openconnect without entering credentials for sudo
add to /etc/sudoers
JOHNDOE ALL=(root) NOPASSWD: /home/JOHNDOE/openconnect/openconnect.sh

VPN-Script is the default openconnect VPN script located at:
/usr/share/vpnc-scripts/vpnc-script

It has two extension to get Zenity notifications when the VPN connects/disconnects:

```
[...]
do_connect() {
        zenity --notification --text "openconnect - connected" 
[...]
do_disconnect() {
        zenity --notification --text "openconnect - disconnected" 
[...]
```

To connect using ocproxy
```
#!/bin/bash
VpnUsername=JOHNDOE
VpnServer=VPN.DOEINC.COM
VpnScript=~/openconnect/openconnect.script
echo $(pass show DOEINC/JOHNDOE) |  openconnect \
        --servercert pin-sha256:eXXXXXXXXXXXXXXXXXXXXXXXXXX= \
        --user=$VpnUsername \
        --authgroup=DOEINC \
        --passwd-on-stdin  \
        --servercert pin-sha256:eXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX \
        --base-mtu=1450 \
        --script-tun \
        --script "/usr/bin/ocproxy \
                -L 443:DOESWEBSERVER:443 \
                -D 11080" \
        $VpnServer
```

To disconnect openconnect VPN
```
sudo pkill --signal SIGINT openconnect
```

