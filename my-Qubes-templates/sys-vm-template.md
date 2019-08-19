# t-fedora-29-sys
a very minimal template to setup your own sys-VMs.
Based on a fedora-29-minimal template.

```
template=fedora-29-minimal
systemplate=t-fedora-29-sys

#remove old template
qvm-kill $systemplate
qvm-remove -f $systemplate

#clone template
qvm-clone $template $systemplate
# update template
qvm-run --auto --user root --pass-io --no-gui $systemplate \
  'dnf update -y'

# install a missing package for fedora-29-minimal
# without it, gui-apps will not start
# not needed in the latest fedora-29-minimal template (after april 2019)
qvm-run --auto --user root --pass-io --no-gui $systemplate \
  'dnf install -y e2fsprogs'

# Install required packages for Sys-VMs
# Hint: you might need to add your own wifi-firmware-drivers here instead of iwl6000g2a...
qvm-run --auto --user root --pass-io --no-gui $systemplate \
  'dnf -y install qubes-core-agent-qrexec qubes-core-agent-systemd \
  qubes-core-agent-networking polkit qubes-core-agent-network-manager \
  notification-daemon qubes-core-agent-dom0-updates qubes-usb-proxy \
  iwl6000g2a-firmware qubes-input-proxy-sender iproute iputils \
  NetworkManager-openvpn NetworkManager-openvpn-gnome \
  NetworkManager-wwan NetworkManager-wifi network-manager-applet'

# Optional packages you might want to install in the sys-template:
qvm-run --auto --user root --pass-io --no-gui $systemplate \
  'dnf -y install nano less pciutils xclip'

# Set new template as template for sys-vms
qvm-shutdown --all --wait --timeout 120
qvm-prefs --set sys-usb template $systemplate
qvm-prefs --set sys-net template $systemplate
qvm-prefs --set sys-firewall template $systemplate
```
