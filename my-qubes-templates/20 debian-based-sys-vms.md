Howto setup a sys template based on Debian 13 minimal
=====================================================

This howto will explain how to build a template whoch can be used for sys-net, sys-usb, sys-firewall.
Instead of using a "full" template this template will be bases on a debian-12-minimal templates which will have a smaller ressource footprint than the default template.
Additionally the template can also be used for a sys-vpn for VPN providers which use OpenVPN or Wireguard.
It has been tested successfully with ProtonVPN using OpenVPN and MullvadVPN using Wireguard.

```
template=debian-13-minimal
systemplate=t_debian-13-sys_v1

#clone template
qvm-clone $template $systemplate

# Conigure locales
qvm-run --auto --user root --pass-io --no-gui $systemplate xterm
# Run the following command in the terminal:
dpkg-reconfigure locales
# install the following locales: 72,97
# 72 = de_DE.UTF-8
# 97 = en_US.UTF-8

# update template
qvm-run --auto --user root --pass-io --no-gui $systemplate \
  'apt-get update && apt-get upgrade && apt autoremove'

# for sys-vms without gnome network manager & drivers (sys-usb / sys-firewall)
# zenity - for file selection dialogs in dom0 (ex: Qubes Backup)
# xfce4-notifyd for popup notifications (or use: dunst + libnotify-bin)

qvm-run --auto --user root --pass-io --no-gui $systemplate \
  'apt-get install \
        qubes-core-agent-networking \
        qubes-menus \
        qubes-mgmt-salt-vm-connector \
        qubes-core-agent-dom0-updates \
        qubes-usb-proxy \
        qubes-input-proxy-sender \
        pulseaudio-qubes \
        xfce4-notifyd \
        net-tools \
	curl'

# for sys-vms with gnome network-manager & drivers (sys-net)
qvm-run --auto --user root --pass-io --no-gui $systemplate \
  'apt-get install \
        network-manager \
        qubes-core-agent-network-manager \
        firmware-iwlwifi \
        modem-manager-gui'

# for vpn-support
qvm-run --auto --user root --pass-io --no-gui $systemplate \
  'apt-get install \
        openvpn wireguard wireguard-tools resolvconf'

# shutdown the template
qvm-shutdown --wait $systemplate

#--- optional stuff, you might want in your sys-xxx templates

# NOT NEEDED, only usefull for troubleshooting/analysis net-tools, iptraf, wget
qvm-run --auto --user root --pass-io --no-gui $systemplate \
  'apt-get install \
        iptraf wget git'

# NOT NEEDED, only if you want to use NetworkManager with VPN
qvm-run --auto --user root --pass-io --no-gui $systemplate \
  'apt-get install \
        network-manager-openconnect \
        network-manager-openconnect-gnome \
        network-manager-openvpn \
        network-manager-openvpn-gnome'

# NOT NEEDED, only for for yubikey-support for login or lockscreen
# you also need to install in dom0 via: sudo qubes-dom0-update install qubes-yubikey-dom0
qvm-run --auto --user root --pass-io --no-gui $systemplate \
  'apt-get install \
        yubikey-personalization'
```

--- EVERYTHING FOR HERE NEEDS TO BE UPDATED TO REFLECT LATEST CHANGES ---

Disposable Sys-VMs
==================
See also: https://qubes-os.org/doc/disposable-customization

Prepare disposable AppVM as template for (named) disposable sys-VMs
-------------------------------------------------------------------
```
sys_template=t_debian-13-sys_v1
dvm_sys_template=sys-dvm

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
# maybe you need to add: -o no-strict-reset=True if sys-net doesn't boot
# Make sure to change the hardware identifiers to the one from your system
qvm-pci attach --persistent -o no-strict-reset=True $netvm dom0:02_00.0 
qvm-pci attach --persistent -o no-strict-reset=True $netvm dom0:00_19.0 

# change clock vm to the new net-VM in "System Tools" > "Qubes Global Settings"
# set new netvm VM for dom0-updates in "System Tools" > "Qubes Global Settings"

# Set new netvm as Update Proxy in dom0
nano /etc/qubes-rpc/policy/qubes.UpdatesProxy

# mount WWAN always
qvm-start sys-usb
qvm-
qvm-usb attach sys-net sys-usb:2-3 --persistent

```

Disposable sys-firewall
-----------------------
```
dvm_sys_template=sys-dvm
fwvm=sys-firewall
netvm=sys-net

# If you need to create a new sys-firewall vm
#qvm-create -C DispVM -l red --template $dvm_sys_template $fwvm
# change the setting of the firewall vm
qvm-kill $fwvm 
qvm-prefs --set $fwvm template $dvm_sys_template
qvm-prefs --set $fwvm memory 400
qvm-prefs --set $fwvm maxmem 1024
qvm-prefs --set $fwvm vcpus 1
qvm-prefs --set $fwvm netvm $netvm
qvm-prefs --set $fwvm autostart true
qvm-prefs --set $fwvm provides_network true
qvm-features  $fwvm appmenus-dispvm ''
qvm-service $fwvm network-manager off
qvm-start $fwvm

# disable old autostart of sys-firewall
#qvm-prefs sys-firewall autostart false
# switch the netvm of all AppVms/templates from sys-fw to the new sys-fw
# Remove old sys-firewall
#qvm-remove -f sys-firewall
```

Disposable sys-usb
------------------
```
dvm_sys_template=sys-dvm
usbvm=sys-usb

# If you need to create a new sys-usb vm
# qvm-create -C DispVM -l green --template $dvm_sys_template $usbvm
# qvm-prefs $usbvm virt_mode hvm
# qvm-prefs $appvm meminfo-writer off
qvm-kill $usbvm
qvm-prefs --set $usbvm template $dvm_sys_template
qvm-prefs $usbvm memory 512
qvm-prefs $usbvm maxmem 0
qvm-prefs $usbvm vcpus 1
qvm-prefs $usbvm netvm ''
qvm-prefs $usbvm autostart true
qvm-prefs $usbvm provides_network true
qvm-service $usbvm network-manager off
qvm-features $usbvm appmenus-dispvm ''
qvm-start $usbvm

# to find out PCI devices
qvm-pci | grep "USB controller"

# add USB controllers to sys-usb
# maybe you need to add: -o no-strict-reset=True
qvm-pci attach --persistent $usbvm -o no-strict-reset=True dom0:00_14.0 
qvm-pci attach --persistent $usbvm -o no-strict-reset=True dom0:00_1a.0 
qvm-pci attach --persistent $usbvm -o no-strict-reset=True dom0:00_1d.0 

# if the name of the usb-qube has changed you must update the settibgs in dom0
# In this example, my USB-qube is named sys-usb
# Link: https://www.qubes-os.org/doc/usb-qubes/
nano /etc/qubes-rpc/policy/qubes.InputMouse 
nano /etc/qubes-rpc/policy/qubes.InputKeyboard 
# content of file:
sys-usb dom0 allow,user=root
$anyvm $anyvm deny
```
