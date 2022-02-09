Debian based minimal sys-vms (including disposable)
===================================================
2022/02/09

Howto setup a sys template based on Debian 11

```
template=debian-11-minimal
systemplate=t_debian-11-sys-gnome

#remove old template
qvm-kill $systemplate
qvm-remove -f $systemplate

#clone template
qvm-clone $template $systemplate

# Conigure locales
qvm-run --auto --user root --pass-io --no-gui $systemplate 'dpkg-reconfigure locales'
# install the following locales:  110,111,112,158
# 110. de_DE ISO-8859-1
# 111. de_DE.UTF-8 UTF-8
# 112. de_DE@euro ISO-8859-15 
# 158. en_US.UTF-8 UTF-8
# Choose the following default locale: 6. en_US.UTF-8

# update template
qvm-run --auto --user root --pass-io --no-gui $systemplate \
  'apt-get update && apt-get -y upgrade && apt autoremove'

# for sys-vms with gnome network-manager & drivers (sys-net / sys-vpn)
qvm-run --auto --user root --pass-io --no-gui $systemplate \
  'apt-get install \
	qubes-core-agent-networking \
	qubes-menus \
	qubes-mgmt-salt-vm-connector \
	network-manager \
	qubes-core-agent-network-manager \
	network-manager-openconnect \
	network-manager-openconnect-gnome \
	network-manager-openvpn \
	network-manager-openvpn-gnome \
	firmware-iwlwifi \
	modem-manager-gui \
	libnotify-bin \
	dunst \
	qubes-usb-proxy'

# optional (installed before but not needed)
#	wireless-tools \
#	usb-modeswitch \
#	notification-daemon \

# for sys-vms without gnome network manager & drivers (sys-usb / sys-firewall)
qvm-run --auto --user root --pass-io --no-gui $systemplate \
  'apt-get install \
	qubes-core-agent-networking \ 
	qubes-menus \
	qubes-mgmt-salt-vm-connector \
	qubes-core-agent-dom0-updates \
	qubes-usb-proxy \
	qubes-input-proxy-sender \
	libnotify-bin \
	dunst'

# optional:
#	zenity - for file selection dialogs in dom0 (ex: Qubes Backup)

# Notification daemons, two options (I prefer dunst)
# 1) dunst libnotify-bin - minimal notification daemon (only one package)
# 2) xfce4-notifyd - default notification daemon, will install the following packages as dependencies:
#        libnotify-bin libstartup-notification0 libxcb-util1 libxfce4panel-2.0-4
#        libxfce4ui-2-0 libxfce4ui-common libxfce4util-bin libxfce4util-common
#        libxfce4util7 libxfconf-0-3 xfconf

## Additional packages (installed in the past, not needed)
#	pciutils usbutils iputils 
#	tar less psmisc nano unzip wget git iproute \
#	qubes-gpg-split notification-daemon locales locales-all \
#	tcpdump telnet nmap nmap-ncat \
#	dbus-x11 polkit @hardware-support


```
Disposable Sys-VMs
==================
See also: https://qubes-os.org/doc/disposable-customization

Prepare disposable AppVM as template for (named) disposable sys-VMs
-------------------------------------------------------------------
```
sys_template=t_debian-11-sys
dvm_sys_template=t_debian-11-sys-dvm

# create a disposable template for the sys-vms
qvm-create --template $sys_template --label red $dvm_sys_template
qvm-prefs $dvm_sys_template template_for_dispvms True
qvm-prefs $dvm_sys_template netvm ''
qvm-features $dvm_sys_template appmenus-dispvm 1
```
Disposable sys-net
------------------
```
dvm_sys_template=t-debian-10-sys-dvm
netvm=sys-net-dvm

qvm-create -C DispVM -l red --template $dvm_sys_template $netvm
qvm-prefs $netvm virt_mode hvm
# qvm-prefs $netvm meminfo-writer off
qvm-prefs $netvm memory 400
qvm-prefs $netvm maxmem 0
qvm-prefs $netvm vcpus 1
qvm-prefs $netvm netvm ''
qvm-service $netvm network-manager on
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
```
Disposable sys-firewall
-----------------------
```
dvm_sys_template=t_debian-11-sys-dvm
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
qvm-service $fwvm network-manager off

# disable old autostart of sys-firewall
qvm-prefs sys-firewall autostart false
# switch the netvm of all AppVms/templates from sys-fw to the new sys-fw
# Remove old sys-firewall
qvm-remove -f sys-firewall
```
Disposable sys-usb
------------------
```
dvm_sys_template=t_debian-11-sys-dvm
usbvm=sys-usb-dvm

qvm-create -C DispVM -l green --template $dvm_sys_template $usbvm
qvm-prefs $usbvm virt_mode hvm
# qvm-prefs $appvm meminfo-writer off
qvm-prefs $usbvm memory 512
qvm-prefs $usbvm maxmem 0
qvm-prefs $usbvm vcpus 1
qvm-prefs $usbvm netvm ''
qvm-prefs $usbvm autostart true
qvm-prefs $usbvm provides_network true
qvm-service $usbvm network-manager off
qvm-features $usbvm appmenus-dispvm ''

# to find out PCI devices
qvm-pci | grep "USB controller"

# add USB controllers to sys-usb
# maybe you need to add: -o no-strict-reset=True
qvm-pci attach --persistent $usbvm -o no-strict-reset=True dom0:00_14.0 
qvm-pci attach --persistent $usbvm -o no-strict-reset=True dom0:00_1a.0 
qvm-pci attach --persistent $usbvm -o no-strict-reset=True dom0:00_1d.0 

# if the name of the usb-qube has changed you must update the settibgs in dom0
# In this example, my USB-qube is named sys-usb-dvm
# Link: https://www.qubes-os.org/doc/usb-qubes/
nano /etc/qubes-rpc/policy/qubes.InputMouse 
nano /etc/qubes-rpc/policy/qubes.InputKeyboard 
# content of file:
sys-usb-dvm dom0 allow,user=root
$anyvm $anyvm deny
```
