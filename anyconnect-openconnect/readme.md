How to use openconnect to connect to an AnyConnect VPN with Qubes OS
====================================================================

```
#!/bin/bash
# Name    : openconnect.sh
# Purpose : Script to autoconnect to a Cisco Anyconnect VPN using openconnect
# Version : v0.1 - draft
# Author  : One7two99
# Install : As root (qvm-run -a -u root APPVM
#           1) mkdir -p /rw/config/openconnect
#           2) Store this script, userpassword.txt and openconnect.conf in /rw/config/openvpn
#           3) Make this script exectable via chmod +x openconnect.sh
#           4) Add this script to /rw/config/rc.local to autorun it
#
# This script uses one file to store the credentials and another file for the VPN configuration.
# /rw/config/openconnect/userpassword.txt:
# username  johndoe
# group mycompany
# password topsecret
#
# Configuration for the VPN is stored in
# /rw/config/openconnect/openconnect.conf:
# vpnserver 212.x.x.x
# servercert pin-sha256:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx=
# port 1194

### Connect via anydesk using openconnect
# Use some variables
hostname=$(hostname)
ConfigDir=/rw/config/openconnect
Credentials=userpassword.txt
Config=openconnect.conf
OpenconnectPidFile=/tmp/openconnect.PID

# Get settings from config file
VpnUsername=`cat $ConfigDir/$Credentials | grep username | gawk '{ print $2 }'`
VpnGroup=`cat $ConfigDir/$Credentials | grep group | gawk '{ print $2 }'`
VpnServer=`cat $ConfigDir/$Config | grep vpnserver | gawk '{ print $2 }'`
VpnPort=`cat $ConfigDir/$Config | grep port | gawk '{ print $2 }'`
VpnServerCert=`cat $ConfigDir/$Config | grep servercert | gawk '{ print $2 }'`

# Launch openconnect
echo $(cat $ConfigDir/$Credentials | grep password | gawk '{ print $2 }') | openconnect \
  --user=$VpnUsername \
  --authgroup=$VpnGroup \
  --protocol=anyconnect  \
  --passwd-on-stdin \
  --servercert=$VpnServerCert \
  --disable-ipv6 \
  --base-mtu=$VpnPort \
  --script=/usr/share/vpnc-scripts/vpnc-script \
  --pid-file=$OpenconnectPidFile \
  --quiet \
  --background \
  $VpnServer

# Enable Routing
echo '1' > /proc/sys/net/ipv4/ip_forward
sleep 3

# Get the VPN DNS servers
ns1=`cat /etc/resolv.conf  | grep nameserver | head -1 | gawk '{ print $2 }'`
ns2=`cat /etc/resolv.conf  | grep nameserver | tail -1 | gawk '{ print $2 }'`
vpn_dns="$ns1 $ns2"

# Flush firewall NAT table
iptables -t nat -F PR-QBS

# Setup firewall DNAT rules for DNS
for DNS in $vpn_dns; do
   iptables -t nat -I PR-QBS -i vif+ -p tcp --dport 53 -j DNAT --to $DNS
   iptables -t nat -I PR-QBS -i vif+ -p udp --dport 53 -j DNAT --to $DNS
done

# Send a notification
echo \'"sleep 2; notify-send \"$hostname: Connected via openconnect.\""\' | xargs su - user -c &```
