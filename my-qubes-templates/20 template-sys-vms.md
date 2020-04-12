 t-fedora-30-sys -> ok
=================
```
template=fedora-30-minimal
systemplate=t-fedora-30-sys

#remove old template
qvm-kill $systemplate
qvm-remove -f $systemplate

#clone template
qvm-clone $template $systemplate
# update template
qvm-run --auto --user root --pass-io --no-gui $systemplate \
  'dnf update -y'

# 25.08.19 gives error for package: initscripts

# Install required packages for Sys-VMs
qvm-run --auto --user root --pass-io --no-gui $systemplate \
  'dnf -y install qubes-core-agent-qrexec qubes-core-agent-systemd \
  qubes-core-agent-networking polkit qubes-core-agent-network-manager \
  notification-daemon qubes-core-agent-dom0-updates qubes-usb-proxy \
  qubes-input-proxy-sender iproute iputils \
  NetworkManager-openvpn NetworkManager-openvpn-gnome \
  NetworkManager-wwan NetworkManager-wifi network-manager-applet'

# See Wifi Drivers: https://www.intel.de/content/www/de/de/support/articles/000005511/network-and-i-o/wireless-networking.html
# Wifi Drivers: 
#    W540 = iwl7260 (iwl7260-firmware)
#    X230 = iwl6000g2a (iwl6000g2a-firmware)
qvm-run --auto --user root --pass-io --no-gui $systemplate \
  'dnf -y install iwl6000g2a-firmware iwl7260-firmware'

# Optional packages you might want to install in the sys-template:
qvm-run --auto --user root --pass-io --no-gui $systemplate \
  'dnf -y install nano less pciutils xclip git unzip wget'

qvm-run --auto --user root --pass-io --no-gui $systemplate \
  'dnf -y install qubes-core-agent-passwordless-root'

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
