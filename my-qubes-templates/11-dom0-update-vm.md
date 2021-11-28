```
templatevm=fedora-34-dvm
appvm=sys-updates-dvm

qvm-create -C DispVM -l red --template $templatevm $appvm
appvm=sys-updates-dvm
qvm-prefs $appvm memory 400
qvm-prefs $appvm maxmem 0
qvm-prefs $appvm vcpus 1
qvm-prefs $appvm memory 512
qvm-prefs $appvm netvm sys-fw-dvm
qvm-prefs $appvm provides_network true
qvm-features $appvm appmenus-dispvm ''
```
