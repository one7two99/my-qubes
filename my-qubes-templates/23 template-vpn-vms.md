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
