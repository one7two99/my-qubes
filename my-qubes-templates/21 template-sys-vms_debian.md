t-debian-10-sys
============
2021/07/24

Howto setup a sys template based on Debian 10

```
template=debian-10-minimal
systemplate=t-debian-10-sys

#remove old template
qvm-kill $systemplate
qvm-remove -f $systemplate

#clone template
qvm-clone $template $systemplate

# update template
qvm-run --auto --user root --pass-io --no-gui $systemplate \
  'apt-get update && apt-get -y upgrade && apt autoremove'

# debian
qvm-run --auto --user root --pass-io --no-gui $systemplate \
  'apt-get install \
	pciutils usbutils less psmisc nano unzip wget git libnotify-bin \
	qubes-core-agent-networking qubes-core-agent-dom0-updates \
	qubes-usb-proxy qubes-input-proxy-sender \
	qubes-menus qubes-gpg-split qubes-mgmt-salt-vm-connector zenity \
	network-manager network-manager-openconnect network-manager-openconnect-gnome \
	network-manager-openvpn network-manager-openvpn-gnome \
	qubes-core-agent-network-manager \
	wireless-tools usb-modeswitch modem-manager-gui firmware-iwlwifi'

# More tools
qvm-run --auto --user root --pass-io --no-gui $systemplate \
  'dnf -y install tcpdump telnet nmap nmap-ncat'


######old

# packages for sys-VMs inluding some tools
# See Wifi Drivers:
# https://www.intel.de/content/www/de/de/support/articles/000005511/network-and-i-o/wireless-networking.html
#    W540 = iwl7260 (iwl7260-firmware)
#    X230 = iwl6000g2a (iwl6000g2a-firmware)



####
dbus-x11 tar tinyproxy iptables gnome-keyring \
iproute git iputils notification-daemon gnome-keyring polkit @hardware-support'


# Wifi drivers
# https://www.intel.de/content/www/de/de/support/articles/000005511/network-and-i-o/wireless-networking.html
#    W540 = iwl7260 (iwl7260-firmware)
#    X230 = iwl6000g2a (iwl6000g2a-firmware)
qvm-run --auto --user root --pass-io --no-gui $systemplate \
  'dnf -y install iwl6000g2a-firmware iwl7260-firmware'
    

# Nice(r) Gnome-Terminal compared to xterm
qvm-run --auto --user root --pass-io --no-gui $systemplate \
  'dnf -y install gnome-terminal terminus-fonts dejavu-sans-fonts \
   dejavu-sans-mono-fonts'
```

Disposable Sys-VMs
==================
See also:
https://qubes-os.org/doc/disposable-customization

```
sys_template=t-debian-10-sys
dvm_sys_template=t-debian-10-sys-dvm

# create a disposable template for the sys-vms
qvm-create --template $sys_template --label red $dvm_sys_template
qvm-prefs $dvm_sys_template template_for_dispvms True
qvm-prefs $dvm_sys_template netvm ''
qvm-features $dvm_sys_template appmenus-dispvm 1



#### disposable sys-net ####
dvm_sys_template=t-debian-10-sys-dvm
netvm=sys-net-dvm

qvm-create -C DispVM -l red --template $dvm_sys_template $netvm
qvm-prefs $netvm virt_mode hvm
# qvm-prefs $netvm meminfo-writer off
qvm-prefs $netvm memory 400
qvm-prefs $netvm maxmem 0
qvm-prefs $netvm vcpus 1
qvm-prefs $netvm netvm ''
qvm-prefs $netvm autostart True
qvm-prefs $netvm provides_network true
qvm-features $netvm appmenus-dispvm ''

# to find out PCI devices
qvm-pci | grep Network && qvm-pci | grep Ethernet

# add Network controllers to sys-net-dvm
# maybe you need to add: -o no-strict-reset=True
qvm-pci attach --persistent -o no-strict-reset=True $netvm dom0:02_00.0 
qvm-pci attach --persistent -o no-strict-reset=True $netvm dom0:00_19.0 

# change clock vm to the new net-VM in "System Tools" > "Qubes Global Settings"

# set new netvm VM for dom0-updates in "System Tools" > "Qubes Global Settings"

# Set new netvm as Update Proxy in dom0
nano /etc/qubes-rpc/policy/qubes.UpdatesProxy



#### disposable sys-fw ####
dvm_sys_template=t-debian-10-sys-dvm
fwvm=sys-fw-dvm
netvm=sys-net

qvm-create -C DispVM -l red --template $dvm_sys_template $fwvm
qvm-prefs $fwvm memory 400
qvm-prefs $fwvm maxmem 1024
qvm-prefs $fwvm vcpus 1
qvm-prefs $fwvm netvm $netvm
qvm-prefs $fwvm autostart true
qvm-prefs $fwvm provides_network true
qvm-features $fwvm appmenus-dispvm ''

# disable old autostart of sys-firewall
qvm-prefs sys-firewall autostart false
# switch the netvm of all AppVms/templates from sys-fw to the new sys-fw
# Remove old sys-firewall
qvm-remove -f sys-firewall



#### disposable sys-usb ####
dvm_sys_template=t-debian-10-sys-dvm
usbvm=sys-usb-dvm

qvm-create -C DispVM -l green --template $dvm_sys_template $usbvm
qvm-prefs $usbvm virt_mode hvm
# qvm-prefs $appvm meminfo-writer off
qvm-prefs $usbvm memory 512
qvm-prefs $usbvm maxmem 0
qvm-prefs $usbvm vcpus 1
qvm-prefs $usbvm netvm ''
qvm-prefs $usbvm autostart true
qvm-prefs $usbvm provides_network false
qvm-features $usbvm appmenus-dispvm ''

# to find out PCI devices
qvm-pci | grep "USB controller"

# add USB controllers to sys-usb
# maybe you need to add: -o no-strict-reset=True
qvm-pci attach --persistent $usbvm -o no-strict-reset=True dom0:00_14.0 
qvm-pci attach --persistent $usbvm -o no-strict-reset=True dom0:00_1a.0 
qvm-pci attach --persistent $usbvm -o no-strict-reset=True dom0:00_1d.0 

# if the name of the usb-qube has changed you must add in dom0
# Link: https://www.qubes-os.org/doc/usb-qubes/
nano /etc/qubes-rpc/policy/qubes.InputMouse 
# content of file:
sys-usb-dvm dom0 allow,user=root
$anyvm $anyvm deny


```
