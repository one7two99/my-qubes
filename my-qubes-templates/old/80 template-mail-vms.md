==================
 t-fedora-33-mail -> ok
==================

--- 8< ---
Template=fedora-33-minimal
TemplateName=t-fedora-33-mail
qvm-kill $TemplateName
qvm-remove --force $TemplateName
qvm-clone $Template $TemplateName

qvm-run --auto --pass-io --no-gui --user root $TemplateName \
  'dnf -y update'

qvm-run --auto --pass-io --no-gui --user root $TemplateName \
  'dnf install -y qubes-usb-proxy nano \
  qubes-gpg-split qubes-core-agent-networking dnf-plugins-core polkit pinentry-gtk \
  thunderbird thunderbird-qubes thunderbird-enigmail dns-utils'


qvm-shutdown $TemplateName 

qvm-create --template=$TemplateName --label=blue my-privmail

### in AppVM > Thunderbird
Download Hide Local Folders

================
t_debian-11-mail
================

Download ProtonBridge in a disposable VM
https://proton.me/mail/bridge#download
Choose the linux .deb package
Copy .deb package to your mail template VM
Switch to the QubesIncoming in your template VM folder where the .deb package has been copied.
Install via: dpkg -i ./protonmail-bridge*.deb



ProtonBridge v2.1.3 --> 2.2.1



