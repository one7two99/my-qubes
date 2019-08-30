template=fedora-29-minimal# sys-vpn - a Proxy VM to hide your traffic from your ISP

Setup of a VPN-ProxyVM to use Private Internet Access to tunnel all traffic through this VPN provider.
This script will build the ProxyVM from scratch using my own t-fedora-29-minimal template and the excellent script from "tasket"

Links:
- https://github.com/tasket/Qubes-vpn-support
- https://www.qubes-os.org/doc/vpn/

```
# A ProxyVM based on my custom fedora-30-minimal sys-template

Template=t-fedora-30-sys
AppVM=sys-vpn
FirewallVM=sys-mirage-fw

# Remove an existing AppVM   
if [ -d /var/lib/qubes/appvms/$AppVM ];
   then qvm-kill $AppVM;
   qvm-remove --force $AppVM;
fi

qvm-create --template=$Template --label=blue $AppVM
qvm-prefs --set $AppVM provides_network True 

qvm-run --auto --pass-io --no-gui --user root $AppVM \
  'mkdir -p /rw/config/vpn && \
   cd /root && \
   git clone https://github.com/tasket/Qubes-vpn-support.git && \
   cd Qubes-vpn-support && \
   bash ./install'

qvm-run --auto --pass-io --no-gui --user root $AppVM \
  'cd /rw/config/vpn && \
   wget https://www.privateinternetaccess.com/openvpn/openvpn-ip.zip && \
   unzip openvpn-ip.zip && \
   # Link to your favorite VPN-Entry Point here: && \
   ln -s Switzerland.ovpn vpn-client.conf'

# Add "vpn-handler-openvpn" to the Settings > Services Tab
qvm-service $AppVM vpn-handler-openvpn on

qvm-shutdown --wait $AppVM
qvm-prefs --set $AppVM netvm sys-net
qvm-start $AppVM

qvm-prefs --set $FirewallVM netvm $AppVM
qvm-prefs --get $FirewallVM netvm

```
If you have questions or comments, do not hesitate to contact me ;-)
