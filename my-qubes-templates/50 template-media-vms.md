===================
 t-fedora-29-media -> ok
===================


Template=fedora-30-minimal
TemplateName=t-fedora-30-media
AppVMName=my-media
qvm-kill $TemplateName
qvm-remove --force $TemplateName
#qvm-start --skip-if-running sys-firewall
qvm-clone $Template $TemplateName
qvm-run --auto --pass-io --no-gui --user root $TemplateName \
  'dnf -y update'

qvm-run --auto --pass-io --no-gui --user root $TemplateName \
  'dnf install -y pulseaudio-qubes qubes-core-agent-networking'

# e2fsprogs

# Install Google Chrome
qvm-run --pass-io --no-gui --user root $TemplateName \
  'dnf install -y fedora-workstation-repositories && \
   dnf config-manager --set-enabled google-chrome && \
   dnf install -y google-chrome-stable'

qvm-shutdown --wait $TemplateName

qvm-create --template=$TemplateName --label=orange $AppVMName

