sys-mullvad - Use MullvadVPN with Wireguard 
===========================================

MullvadVPN is an excellent VPN Provider which is easy to setup has a simple and fair pricing modell, which doesn't offer huge and unrealistic discount and isn't interesting in collecting data about you.
You can use Mullvad without giving any personal details and pay by cash, crypto and all other common methods.

sys-mullvad will be based on my minimal sys-template, which is an adapted clone of debian-12-minimal.
Howto to build this sys-template is covered here:
https://github.com/one7two99/my-qubes/blob/master/my-qubes-templates/20%20debian-based-sys-vms.md

```
mytemplate=t_debian-12-sys_v1
vpnvm=sys-mullvad
netvm=sys-fw-1

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
# Copy the file from your "downloadvm" to /home/user/wireguard.conf in the VPNVM
qvm-run --pass-io --no-gui $downloadvm \
        'cat ~/Downloads/*-wg-*.conf' \
        | qvm-run --pass-io --no-gui $vpnvm \
                "cat - > /home/user/wireguard.conf"

# Launch Wireguard and make a connection test
qvm-run --pass-io --no-gui --user=root $vpnvm "wg-quick up /home/user/wireguard.conf"
# Check if connected
qvm-run --pass-io --no-gui $vpnvm "curl https://am.i.mullvad.net/connected"
# Stop Wireguard
qvm-run --pass-io --no-gui --user=root $vpnvm "wg-quick down /home/user/wireguard.conf"
# Check if unconnected / should show a different IP than beeing connected
qvm-run --pass-io --no-gui $vpnvm "curl https://am.i.mullvad.net/connected"

# let wireguard connect automatically when starting up the NetVM
qvm-run --pass-io --no-gui --user=root $vpnvm "echo wg-quick up /home/user/wireguard.conf >> /rw/config/rc.>
# Restart the NetVM
qvm-shutdown --wait $vpnvm
# Check if connected to Mullvad after boot
qvm-run --auto --pass-io --no-gui $vpnvm "curl https://am.i.mullvad.net/connected"

# Start another AppVM and set the Mullvad Proxy as NetVM for this VM
# Try to connect to the internet using this VM
qvm-run --auto --pass-io --no-gui OTHERAPPVMNAME "curl https://am.i.mullvad.net/connected"

# Only allow outbound traffic from your Mullvad VPN proxy to mullvad's VPN server
# get the wireguard IP-address from your wireguard config file from the line starting with Endpoint
qvm-run --pass-io --no-gui $vpnvm "cat /home/user/wireguard.conf" | grep Endpoint
# Change this to the correct IP (see outout of above command)
wireguardip=185.213.154.68
# reset firewall rules
qvm-firewall $vpnvm reset
# delete the default "Allow all" rule
qvm-firewall $vpnvm del --rule-no 0
# Allow only outbound Mullvad connection
qvm-firewall $vpnvm add action=accept dsthost=$wireguardip/32 comment="Allow Mullvad"
# Block everything else
qvm-firewall $vpnvm add action=drop comment="Drop everything else"
# List the new rules
qvm-firewall $vpnvm list

# Test Leakage protection
# Open a new dom0-Terminal and ping from your APPVM
qvm-run --pass-io --no-gui YOURAPPVM "ping 8.8.8.8"

# Disconnect the wireguard connection and the ping in your AppVM should stop working
qvm-run --pass-io --no-gui --user=root $vpnvm "wg-quick down /home/user/wireguard.conf"

# To setup DNS Hijacking Rules see: https://mullvad.net/en/help/wireguard-on-qubes-os/
# I am using a sys-pihole Proxy with unbound and NextDNS as such I have a different setup

# Happy MullvadVPN'ing :-)
```


Use ProtonVPN in Qubes via an OpenVPN NetVM
===========================================

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
