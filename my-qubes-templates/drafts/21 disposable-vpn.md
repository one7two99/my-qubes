Disposable Sys-VPN
==================

```
templatevm=t_debian-11-sys-dvm
vpnvm=sys-protonvpn
netvm=sys-net

qvm-create -C DispVM -l red --template $templatevm $vpnvm
qvm-prefs $vpnvm vcpus 1
qvm-prefs $vpnvm memory 256
qvm-prefs $vpnvm maxmem 512
qvm-prefs $vpnvm netvm $netvm
qvm-prefs $netvm provides_network true
qvm-features $vpnvm appmenus-dispvm ''
