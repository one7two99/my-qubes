==================
 t-fedora-32-apps -> ok
==================

Template=fedora-32-minimal
TemplateName=t-fedora-32-apps
qvm-kill $TemplateName
qvm-remove --force $TemplateName
qvm-clone $Template $TemplateName
qvm-run --auto --pass-io --no-gui --user root $TemplateName \
  'dnf -y update'

qvm-run --auto --pass-io --no-gui --user root $TemplateName \
  'dnf install -y emacs keepass klavaro libreoffice gedit gimp \
  firefox qubes-usb-proxy pulseaudio-qubes nano git transmission mc \
  transmission-cli less qubes-gpg-split qubes-core-agent-networking unzip \
  nautilus wget qubes-core-agent-nautilus gnome-terminal-nautilus evince \
  polkit e2fsprogs gnome-terminal terminus-fonts dejavu-sans-fonts \
  dejavu-sans-mono-fonts xclip pinentry-gtk \
  evince-nautilus nautilus-sendto nautilus-search-tool'

qvm-shutdown --wait $TemplateName

# set App-template as defaut template
qubes-prefs --set default_template $TemplateName

