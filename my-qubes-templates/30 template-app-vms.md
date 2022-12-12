 Template for general a productivity VM
=======================================

## fedora
```
Template=fedora-35-minimal
TemplateName=t_fedora-35-apps

qvm-kill $TemplateName
qvm-remove --force $TemplateName
qvm-clone $Template $TemplateName
#qvm-run --auto --pass-io --no-gui --user root $TemplateName 'dnf -y update'
  
qvm-run --auto --pass-io --no-gui --user root $TemplateName 'dnf install -y \
	qubes-core-agent-networking \
	qubes-usb-proxy \
	pulseaudio-qubes \
	qubes-gpg-split \
	qubes-mgmt-salt-vm-connector \
	zenity \
	keepassxc \
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

qvm-run --auto --pass-io --no-gui --user root $TemplateName 'dnf install -y \
	--allowerasing pulseaudio-qubes pulseaudio'
```

# Problem installing qubes-pulseaudio under fedora-36
```
qvm-run --auto --pass-io --no-gui --user root $TemplateName 'dnf install -y \
        keepass'
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

## more apps
```
qvm-run --auto --pass-io --no-gui --user root $TemplateName \
  'dnf install -y emacs transmission transmission-cli \
  gnome-terminal-nautilus polkit e2fsprogs gnome-terminal \
  terminus-fonts dejavu-sans-fonts dejavu-sans-mono-fonts xclip'
```

## set App-template as defaut template
```
qubes-prefs --set default_template $TemplateName
```

# Shutdown
```
qvm-shutdown --wait $TemplateName
```

# Set this template as Template for specific AppVMs
```
MyAppVM=my-untrusted
qvm-prefs --set $MyAppVM template $TemplateName
```

# Set this template as template for management VM
```
qvm-prefs --set default-mgmt-dvm template $TemplateName
```
