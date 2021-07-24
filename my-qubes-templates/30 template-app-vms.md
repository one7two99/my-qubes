==================
 t-fedora-32-apps -> ok
==================

Template=fedora-33-minimal
TemplateName=t-fedora-33-apps
qvm-kill $TemplateName
qvm-remove --force $TemplateName
qvm-clone $Template $TemplateName
qvm-run --auto --pass-io --no-gui --user root $TemplateName \
  'dnf -y update'

# fedora
qvm-run --auto --pass-io --no-gui --user root $TemplateName \
  'dnf install -y keepass klavaro libreoffice gedit gimp \
  firefox qubes-usb-proxy pulseaudio-qubes nano git mc evince \
  less qubes-gpg-split qubes-core-agent-networking unzip \
  nautilus wget qubes-core-agent-nautilus evince pinentry-gtk \
  evince-nautilus nautilus-sendto nautilus-search-tool'

# debian
qvm-run --auto --pass-io --no-gui --user root $TemplateName \
  'apt-get install -y keepass2 klavaro libreoffice gedit gimp \
  firefox-esr qubes-usb-proxy pulseaudio-qubes nano git mc evince \
  less qubes-gpg-split qubes-core-agent unzip \
  nautilus wget qubes-core-agent-nautilus evince pinentry-gtk2'

# more apps
qvm-run --auto --pass-io --no-gui --user root $TemplateName \
  'dnf install -y emacs transmission transmission-cli \
  gnome-terminal-nautilus polkit e2fsprogs gnome-terminal \
  terminus-fonts dejavu-sans-fonts dejavu-sans-mono-fonts xclip'

qvm-shutdown --wait $TemplateName

# set App-template as defaut template
qubes-prefs --set default_template $TemplateName

