 t-fedora-32-sys -> ok
=================
```
template=fedora-32-minimal
systemplate=t-fedora-32-sys

#remove old template
qvm-kill $systemplate
qvm-remove -f $systemplate

#clone template
qvm-clone $template $systemplate

# update template
qvm-run --auto --user root --pass-io --no-gui $systemplate \
  'dnf update -y'

# packages for sys-VMs inluding some tools
# See Wifi Drivers:
# https://www.intel.de/content/www/de/de/support/articles/000005511/network-and-i-o/wireless-networking.html
#    W540 = iwl7260 (iwl7260-firmware)
#    X230 = iwl6000g2a (iwl6000g2a-firmware)
qvm-run --auto --user root --pass-io --no-gui $systemplate \
  'dnf -y install NetworkManager NetworkManager-wifi network-manager-applet \
  wireless-tools dbus-x11 tar tinyproxy iptables usbutils \
  NetworkManager-openconnect NetworkManager-openconnect-gnome \
  NetworkManager-openvpn NetworkManager-openvpn-gnome \
  NetworkManager-wwan usb_modeswitch modem-manager-gui \
  pciutils nano less psmisc qubes-core-agent-networking iproute \
  qubes-core-agent-dom0-updates qubes-core-agent-network-manager \
  notification-daemon gnome-keyring polkit @hardware-support \
  tcpdump telnet nmap nmap-ncat qubes-usb-proxy qubes-input-proxy-sender \
  iwl6000g2a-firmware iwl7260-firmware qubes-menus qubes-gpg-split \
  xclip git unzip wget'
  
  
# Nice(r) Gnome-Terminal compared to xterm
qvm-run --auto --user root --pass-io --no-gui $systemplate \
  'dnf -y install gnome-terminal terminus-fonts dejavu-sans-fonts \
   dejavu-sans-mono-fonts'


# Set new template as template for sys-vms
qvm-shutdown --all --wait --timeout 120
qvm-prefs --set sys-usb template $systemplate
qvm-prefs --set sys-net template $systemplate
qvm-prefs --set sys-firewall template $systemplate
#qvm-prefs --set sys-vpn template $systemplate
```
