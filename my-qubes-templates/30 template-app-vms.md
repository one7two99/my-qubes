 Template for general a productivity VM
=======================================

## fedora
```
Template=fedora-34-minimal
TemplateName=t_fedora-34-apps

qvm-kill $TemplateName
qvm-remove --force $TemplateName
qvm-clone $Template $TemplateName
qvm-run --auto --pass-io --no-gui --user root $TemplateName \
  'dnf -y update'
  
qvm-run --auto --pass-io --no-gui --user root $TemplateName 'dnf install -y \
	qubes-usb-proxy \
	pulseaudio-qubes \
	qubes-gpg-split \
	qubes-core-agent-networking \
	qubes-mgmt-salt-vm-connector \
	zenity \
	keepass \
	klavaro \
	libreoffice \
	gedit \
	gimp \
	firefox \
	nautilus \
	qubes-core-agent-nautilus \
	nautilus-search-tool \
	evince \
	evince-nautilus \
	pinentry-gtk \
	unzip \
	nano \
	git \
	mc \
	less \
	wget \
	borgbackup'
```

## debian
```
Template=debian-10-minimal
TemplateName=t-debian-10-apps

qvm-kill $TemplateName
qvm-remove --force $TemplateName
qvm-clone $Template $TemplateName
qvm-run --auto --pass-io --no-gui --user root $TemplateName \
  'apt-get update && apt-get -y upgrade'

qvm-run --auto --pass-io --no-gui --user root $TemplateName \
  'apt-get install -y keepass2 klavaro libreoffice gedit gimp \
  firefox-esr qubes-usb-proxy pulseaudio-qubes nano git mc evince \
  less qubes-gpg-split qubes-core-agent unzip \
  nautilus wget qubes-core-agent-nautilus evince pinentry-gtk2 borgbackup'
```

## set App-template as defaut template
```
qubes-prefs --set default_template $TemplateName
```

## more apps
```
qvm-run --auto --pass-io --no-gui --user root $TemplateName \
  'dnf install -y emacs transmission transmission-cli \
  gnome-terminal-nautilus polkit e2fsprogs gnome-terminal \
  terminus-fonts dejavu-sans-fonts dejavu-sans-mono-fonts xclip'

qvm-shutdown --wait $TemplateName
```

