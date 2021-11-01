Fedora based sys-vms (including disposables)
============================================
Last change: 2021/11/01

Howto setup a sys-template based on fedora minimal

```
template=fedora-33-minimal
systemplate=t-fedora-33-sys

#remove old template
qvm-kill $systemplate
qvm-remove -f $systemplate

#clone template
qvm-clone $template $systemplate

# update template
qvm-run --auto --user root --pass-io --no-gui $systemplate \
  'dnf update -y'

# Install packages for sys-VMs
qvm-run --auto --user root --pass-io --no-gui $systemplate \
  'dnf -y install NetworkManager NetworkManager-wifi network-manager-applet \
  wireless-tools dbus-x11 tar tinyproxy iptables usbutils \
  NetworkManager-openconnect NetworkManager-openconnect-gnome \
  NetworkManager-openvpn NetworkManager-openvpn-gnome \
  NetworkManager-wwan usb_modeswitch modem-manager-gui \
  pciutils nano less psmisc qubes-core-agent-networking iproute \
  qubes-core-agent-dom0-updates qubes-core-agent-network-manager \
  notification-daemon gnome-keyring polkit @hardware-support \
  qubes-usb-proxy qubes-input-proxy-sender iputils \
  qubes-menus qubes-gpg-split git unzip wget'

# See Wifi Drivers:
# https://www.intel.de/content/www/de/de/support/articles/000005511/network-and-i-o/wireless-networking.html
#    W540/X270 = iwl7260 (iwl7260-firmware)
#    X230 = iwl6000g2a (iwl6000g2a-firmware)
qvm-run --auto --user root --pass-io --no-gui $systemplate \
  'dnf -y install iwl6000g2a-firmware iwl7260-firmware'

```

Disposable Sys-VMs
==================
See also: https://qubes-os.org/doc/disposable-customization

Prepare disposable AppVM as template for (named) disposable sys-VMs
-------------------------------------------------------------------
```
sys_template=t-fedora-33-sys
dvm_sys_template=t-fedora-33-sys-dvm

# create a disposable template for the sys-vms
qvm-create --template $sys_template --label red $dvm_sys_template
qvm-prefs $dvm_sys_template template_for_dispvms True
qvm-prefs $dvm_sys_template netvm ''
qvm-features $dvm_sys_template appmenus-dispvm 1
```
Disposable sys-net
------------------
```
#### disposable sys-net ####
dvm_sys_template=t-fedora-33-sys-dvm
appvm=sys-net-dvm

qvm-create -C DispVM -l red --template $dvm_sys_template $appvm
qvm-prefs $appvm virt_mode hvm
# qvm-prefs $appvm meminfo-writer off
qvm-prefs $appvm memory 400
qvm-prefs $appvm maxmem 0
qvm-prefs $appvm vcpus 1
qvm-prefs $appvm netvm ''
qvm-prefs $appvm autostart True
qvm-prefs $appvm provides_network true
qvm-features $appvm appmenus-dispvm ''

# to find out PCI devices
qvm-pci | grep Network && qvm-pci | grep Ethernet

# add Network controllers to sys-net-dvm
# maybe you need to add: -o no-strict-reset=True
qvm-pci attach --persistent -o no-strict-reset=True $appvm dom0:02_00.0 
qvm-pci attach --persistent -o no-strict-reset=True $appvm dom0:00_19.0 

# change clock vm to the new net-VM in "System Tools" > "Qubes Global Settings"
```
Disposable sys-firewall
-----------------------
```
dvm_sys_template=t-fedora-33-sys-dvm
appvm=sys-fw-dvm
netvm=sys-net-dvm

qvm-create -C DispVM -l red --template $dvm_sys_template $appvm
qvm-prefs $appvm memory 400
qvm-prefs $appvm maxmem 1024
qvm-prefs $appvm vcpus 1
qvm-prefs $appvm netvm $netvm
qvm-prefs $appvm autostart true
qvm-prefs $appvm provides_network true
qvm-features $appvm appmenus-dispvm ''

# disable old autostart of sys-firewall
qvm-prefs sys-firewall autostart false
# switch the netvm of all AppVms/templates from sys-fw to the new sys-fw
qvm-remove -f sys-firewall

# set new firewall VM for dom0-updates in "System Tools" > "Qubes Global Settings"
# nano /etc/qubes-rpc/policy/qubes.UpdatesProxy
```
Disposable sys-usb
------------------
```
dvm_sys_template=t-fedora-33-sys-dvm
appvm=sys-usb-dvm

qvm-create -C DispVM -l green --template $dvm_sys_template $appvm
qvm-prefs $appvm virt_mode hvm
# qvm-prefs $appvm meminfo-writer off
qvm-prefs $appvm memory 512
qvm-prefs $appvm maxmem 0
qvm-prefs $appvm vcpus 1
qvm-prefs $appvm netvm ''
qvm-prefs $appvm autostart true
qvm-prefs $appvm provides_network false
qvm-features $appvm appmenus-dispvm ''

# to find out PCI devices
qvm-pci | grep "USB controller"

# add USB controllers to sys-usb
# maybe you need to add: -o no-strict-reset=True
qvm-pci attach --persistent $appvm -o no-strict-reset=True dom0:00_14.0 
qvm-pci attach --persistent $appvm -o no-strict-reset=True dom0:00_1a.0 
qvm-pci attach --persistent $appvm -o no-strict-reset=True dom0:00_1d.0 

# if the name of the usb-qube has changed you must add in dom0
# Link: https://www.qubes-os.org/doc/usb-qubes/
nano /etc/qubes-rpc/policy/qubes.InputMouse 
nano /etc/qubes-rpc/policy/qubes.InputKeyboard
# content of file:
sys-usb-dvm dom0 allow,user=root
$anyvm $anyvm deny
```
