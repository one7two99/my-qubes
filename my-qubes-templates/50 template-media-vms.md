t-fedora-32-media
=================
## Debian based
See also: https://linuxize.com/post/how-to-install-google-chrome-web-browser-on-debian-10/
```
Template=debian-10-minimal
TemplateName=t-debian-10-media
AppVMName=my-media
qvm-clone $Template $TemplateName
qvm-run --auto --pass-io --no-gui --user root $TemplateName 'apt-get update && apt-get -y upgrade && apt autoremove'
qvm-run --auto --pass-io --no-gui --user root $TemplateName 'apt-install /home/user/QubesIncoming/*/google-chrome-stable_current_amd64.deb'
qvm-run --auto --pass-io --no-gui --user root $TemplateName 'apt-get update && apt-get -y upgrade && apt autoremove'
qvm-run --auto --pass-io --no-gui --user root $TemplateName 'rm /home/user/QubesIncoming/*/google-chrome-stable_current_amd64.deb'
qvm-shutdown --wait $TemplateName 
qvm-create --template=$TemplateName --label=orange $AppVMName
```

## Fedora based
```
Template=fedora-32-minimal
TemplateName=t-fedora-32-media
AppVMName=my-media
qvm-kill $TemplateName
qvm-remove --force $TemplateName
qvm-clone $Template $TemplateName
qvm-run --auto --pass-io --no-gui --user root $TemplateName \
  'dnf -y update'

qvm-run --auto --pass-io --no-gui --user root $TemplateName \
  'dnf install -y pulseaudio-qubes qubes-core-agent-networking'

# Install Google Chrome
qvm-run --pass-io --no-gui --user root $TemplateName \
  'dnf install -y fedora-workstation-repositories && \
   dnf config-manager --set-enabled google-chrome && \
   dnf install -y google-chrome-stable'

qvm-shutdown --wait $TemplateName

qvm-create --template=$TemplateName --label=orange $AppVMName
```

y
