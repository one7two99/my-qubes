sys-protonvpn
-----------------------
```
sys_template=t_debian-11-sys-gnome
vpnvm=sys-protonvpn
netvm=sys-net

qvm-create -C AppVM -l red --template $sys_template $vpnvm
qvm-prefs $vpnvm memory 400
qvm-prefs $vpnvm maxmem 1024
qvm-prefs $vpnvm vcpus 1
qvm-prefs $vpnvm netvm $netvm
qvm-prefs $vpnvm autostart true
qvm-prefs $vpnvm provides_network true
qvm-service $vpnvm network-manager off

# disable old autostart of sys-firewall
#qvm-prefs sys-firewall autostart false
# switch the netvm of all AppVms/templates from sys-fw to the new sys-fw
# Remove old sys-firewall
#qvm-remove -f sys-firewall
