sys-protonvpn - Use ProtonVPN with Wireguard 
============================================

MullvadVPN and also ProtonVPN are excellent VPN Providers which are easy to setup.
ProtonVPN can also be bought via the Proton Unlimited Bundle.
MullvadVPN has a simple and fair pricing modell, which doesn't offer huge and unrealistic discounts
and isn't interesting in collecting data about you.
You can use Mullvad without giving any personal details and pay by cash, crypto and all other common methods.

The way I have setup my VPNs:
```
sys-net <- sys-fw1 <- sys-vpn <- sys-fw2 <- AppVMs via VPN
sys-net <- sys-fw1 <- AppVMs direct connection
```

The VPN Qube will be based on my minimal sys-template, which is an adapted clone of debian-13-minimal.
Howto to build this sys-template is covered here:
https://github.com/one7two99/my-qubes/blob/master/my-qubes-templates/20%20debian-based-sys-vms.md
```
mytemplate=t_debian-13-sys_v1
vpnvm=sys-vpn
netvm=sys-firewall

# Create vpn NetVM
qvm-create -l orange --template $mytemplate $vpnvm
qvm-prefs $vpnvm memory 400
qvm-prefs $vpnvm maxmem 1024
qvm-prefs $vpnvm vcpus 1
# If you can't set the next two option via CLI, use Qubes Settings for the vpnvm
qvm-prefs $vpnvm netvm $netvm
qvm-prefs $vpnvm provides_network true

# Create a wireguard-config file and copy it to vpnvm
# Assume that you downloaded the wireguard-config file to the Downloads folder
downloadvm=my-untrusted
# Copy the file from your "downloadvm" to /home/user/wireguard.conf in the VPN-VM
# rename the file to wireguard.conf if is has another name.
qvm-run --pass-io --no-gui $downloadvm \
        'cat ~/Downloads/wireguard.conf' \
         | qvm-run --pass-io --no-gui $vpnvm \
             "cat - > /home/user/wireguard.conf"

# only allow traffic to the VPN-VM
# show the VPN-IP from the wireguard config-file
qvm-run --pass-io --no-gui $vpnvm "cat /home/user/wireguard.conf" | grep Endpoint
# set the wireguard IP
wireguardip=79.135.104.69
# reset firewall
qvm-firewall sys-vpn reset
# delete the default role
qvm-firewall $vpnvm del --rule-no 0
# only allow traffic to the VPN-IP
qvm-firewall $vpnvm add action=accept dsthost=$wireguardip/32 comment="Allow ProtonVPN via Wireguard"
qvm-firewall $vpnvm add action=drop comment="Drop everything else"
qvm-firewall $vpnvm list

# Enable network-manager in the vpn-vm
qvm-service --enable $vpnvm network-manager

# Restart the vm
qvm-shutdown --wait $vpnvm
qvm-start $vpnvm

# Import wireguard-config in network-manager
qvm-run --pass-io --user=root $vpnvm "nmcli connection import type wireguard file /home/user/wireguard.conf"

# launch the vpn connection on startup
qvm-run --pass-io --no-gui --user=root sys-protonvpn "echo nmcli connection up wireguard >> /rw/config/rc.local"

# Test Leakage protection
# connect to vpn
qvm-run --pass-io --user=root $vpnvm "nmcli connection up wireguard"
# Check if connected
qvm-run --pass-io --no-gui $vpnvm "curl https://am.i.mullvad.net/connected"
# Open a new dom0-Terminal and ping from another appvm
anotherappvm=my-untrusted
sysvpn=sys-vpn
# set vpn as netvm
qvm-prefs --set $anotherappvm netvm sys-vpn
# ping to google dns as test in the appvm (ping 8.8.8.8)
qvm-run --pass-io --no-gui $vpnvm "ping 8.8.8.8"
# In the other window: disconnect wireguard connection -> ping in your AppVM should stop working
qvm-run --pass-io --user=root $vpnvm "nmcli connection down wireguard"
```

Use ProtonVPN in Qubes via an OpenVPN NetVM
===========================================
INFO: this howto is not up to date for debian-13 as wireguard is the superior vpn protocol for me.

This "sys-protonvpn" will act as a NetVM (VPN-Proxy) for all Qubes which are using this qubes as NetVM.
It's based on my t_debian-11-sys template which is itself based on a customized debian-11-minimal template.
Information how this template has been built can be found here:
https://github.com/one7two99/my-qubes/blob/master/my-qubes-templates/20%20debian-based-sys-vms.md

I'm running this VPN-Proxy-VPN in the following setup:

sys-net <- sys-firewall2 <- sys-protonvpn <- sys-firewall1 <- sys-pihole <- <OTHER QUBES>
	
```
templatevm=t_debian-11-sys
vpnvm=sys-protonvpn
netvm=sys-net

# install VPN script in templatevm
qvm-prefs $templatevm netvm $netvm
qvm-run --auto --pass-io --no-gui --user root $templatevm  \
   'mkdir -p /rw/config/vpn && \
    cd /root && \
    git clone https://github.com/tasket/Qubes-vpn-support.git && \
    cd Qubes-vpn-support && \
    bash ./install'
qvm-prefs $templatevm netvm ''
qvm-shutdown --wait $templatevm

# Create vpn NetVM
qvm-create -l orange --template $templatevm $vpnvm
qvm-prefs $vpnvm memory 400
qvm-prefs $vpnvm maxmem 1024
qvm-prefs $vpnvm vcpus 1
qvm-prefs $vpnvm netvm $netvm
qvm-prefs $vpnvm provides_network true
qvm-service $vpnvm vpn-handler-openvpn on

#set bind dirs in VPNvm
qvm-run --auto --pass-io --user root $vpnvm 'xterm -e \
  "mkdir -p /rw/config/qubes-bind-dirs.d"'

qvm-run --auto --pass-io --user root $vpnvm 'xterm -e "nano /rw/config/qubes-bind-dirs.d/50_user.conf"'
# add: binds+=( '/usr/lib/qubes' )
# add: binds+=( '/rw/config/vpn' )
qvm-shutdown --wait $vpnvm

# Copy the content from your ProtonVPN OpenVPN-Config file to clipboard
qvm-run --auto --pass-io --user root $vpnvm 'xterm -e "nano /rw/config/vpn/vpn-client.conf"'
# Paste it into the VPN-VM to /rw/config/vpn/vpn-client.conf
# using Qubes Shift+Strg+C and Shift+Strg+V top copy & past between Qubes
# To link to your username/password file vhange the line
auth-user-info
# to
auth-user-info user-password.txt

# run config script and add your credentials
# Credentials can be found in ProtonVPN WebGUI under OpenVPN/IKEv2
qvm-run --auto --pass-io --user root $vpnvm 'xterm -e "/usr/lib/qubes/qubes-vpn-setup --config"'

# check credentials
qvm-run --auto --pass-io --user root --pass-io $vpnvm 'cat /rw/config/vpn/userpassword.txt'

# Shutdown VPN-Qube
qvm-shutdown --wait $vpnvm

# Use this VPNvm as netvm on all qubes which should connect via VPN
```
