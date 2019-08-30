==================
 t-fedora-30-apps -> ok
==================

Template=fedora-30-minimal
TemplateName=t-fedora-30-apps
qvm-kill $TemplateName
qvm-remove --force $TemplateName
qvm-start --skip-if-running sys-firewall
qvm-clone $Template $TemplateName
qvm-run --auto --pass-io --no-gui --user root $TemplateName \
  'dnf -y update'

Error-Message:
Failed:
  initscripts-10.02-1.fc30.x86_64

# install a missing package for fedora-29-minimal
# without it, gui-apps will not start
# qvm-run --auto --user root --pass-io --no-gui $systemplate \
#  'dnf install -y e2fsprogs'

qvm-run --auto --pass-io --no-gui --user root $TemplateName \
  'dnf install -y emacs keepass klavaro libreoffice gedit gimp \
  firefox qubes-usb-proxy pulseaudio-qubes nano git transmission mc \
  transmission-cli less qubes-gpg-split qubes-core-agent-networking unzip \
  nautilus wget qubes-core-agent-nautilus gnome-terminal-nautilus evince \
  polkit e2fsprogs gnome-terminal terminus-fonts dejavu-sans-fonts \
  dejavu-sans-mono-fonts xclip pinentry-gtk \
  evince-nautilus nautilus-sendto nautilus-pastebin nautilus-search-tool'

qvm-shutdown --wait $TemplateName

# set App-template as defaut template
qubes-prefs --set default_template $TemplateName

