Fedora-39-minimal based sys-vm-template for Qubes 4.2
=====================================================
This template can be used for sys-net, sys-usb, sys-firewall under Qubes 4.2.
Additionally it can be used for a VPN/ProxyVM which uses Wireguard.
Recommendation for VPN providers: MullvadVPN or ProtonVPN.

```
QubesTemplate=fedora-39-minimal
MySysTemplate=t_fedora-39-sys_v3

qvm-clone $QubesTemplate $MySysTemplate

# Update Template
qvm-run --auto --user root --pass-io --no-gui $MySysTemplate "dnf update"

# Install additional packages which are needed to use the new template as template for sys-vms
# See also: https://www.qubes-os.org/doc/templates/minimal/#customization
qvm-run --auto --user root --pass-io --no-gui $MySysTemplate \
        "dnf install \
                gnome-keyring \
                pciutils \
                less \
                psmisc \
                qubes-core-agent-networking \
                iproute \
                qubes-core-agent-dom0-updates \
                qubes-core-agent-network-manager \
                NetworkManager-wifi \
                network-manager-applet \
                notification-daemon \
                polkit @hardware-support \
                qubes-usb-proxy \
                qubes-input-proxy-sender \
                qubes-core-agent-passwordless-root \
                qubes-mgmt-salt-vm-connector \
                qubes-menus \
                iptraf-ng net-tools nano git wireguard-tools"

# additional packages for other VPNs and to use WWAN (like internal 3G/LTE cards)
qvm-run --auto --user root --pass-io --no-gui $MySysTemplate \
        "dnf install \
                NetworkManager-openconnect-gnome \
                NetworkManager-openvpn-gnome \
                NetworkManager-ppp \
                NetworkManager-wwan"

# Shutdown Template
qvm-shutdown --wait $MySysTemplate

### Create Wireguard ProxyVM
MySysTemplate=t_fedora-39-sys_v3
proxyvm=sys-protonvpn1
NetVM=sys-fw1
qvm-create -l orange --template $MySysTemplate $proxyvm
qvm-prefs $proxyvm memory 400
qvm-prefs $proxyvm maxmem 1024
qvm-prefs $proxyvm vcpus 2
qvm-prefs $proxyvm netvm $NetVM
qvm-prefs $proxyvm autostart false
qvm-prefs $proxyvm provides_network true
qvm-service $proxyvm network-manager on

### Download the wireguard configuration file from your VPN Provider in another AppVM
### Copy wireguard config file to the $proxyvm via right click, "Copy to other qube"

# Show Wireguard Endpoint IP and Port
WireguardConfig=ProtonVPN-CH-DE.conf
qvm-run --auto --pass-io $proxyvm "cat ~/QubesIncoming/*/$WireguardConfig | grep Endpoint"

# Setup qvm-firewall to only allow traffic to the Wireguard Endpoint -> leak protection
WireguardGateway=185.159.157.58
WireguardPort=51820
qvm-firewall $proxyvm reset
qvm-firewall $proxyvm del --rule-no 0
qvm-firewall $proxyvm add action=accept dsthost=$WireguardGateway proto=udp dstports=$WireguardPort comment="Allow Wireguard VPN"
qvm-firewall $proxyvm add action=drop comment="Drop everything else"
qvm-firewall $proxyvm

# Import wireguard config file into Network Manager
qvm-run --auto --pass-io --user root $proxyvm "nmcli connection import type wireguard file /home/user/QubesIncoming/*/$WireguardConfig"

# Shutdown ProxyVM
qvm-shutdown --wait $proxyvm

# Restart to check if the ProxyVM autoconnects via the wireguard VPN
qvm-start $proxyvm
```
