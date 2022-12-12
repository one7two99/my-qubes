Template for a Multimedia AppVM
===============================
This template can be used to have an AppVM which has Google Chrome, Open Broadcaster Studio, VideoLAN Client (VLC) and Audacity installed.
With Google Chrome you can use all streaming services like Amazon Prime, Netflix etc.
Open Broadcaster and Audicity can be used to create multimedia content for Streamcasting or Podcasts.

## Debian 11 based
```
Template=debian-11-minimal
TemplateName=t_debian-11-media
AppVMName=my-media
netvm=sys-net
qvm-clone $Template $TemplateName

qvm-run --auto --pass-io --no-gui --user root $TemplateName \
	'apt-get update && apt-get -y upgrade && apt autoremove'

qvm-run --auto --pass-io --no-gui --user root $TemplateName \
	'apt-get install \
		zenity \
		qubes-core-agent-networking \
		pulseaudio-qubes \
		wget \
		qubes-usb-proxy'

qvm-run --auto --pass-io --no-gui --user root $TemplateName \
	'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list'

# Enable networking for template
qvm-prefs $TemplateName netvm $netvm
qvm-run --auto --pass-io --no-gui --user root $TemplateName \
	'wget -O- https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor > /etc/apt/trusted.gpg.d/google.gpg'

qvm-run --auto --pass-io --no-gui --user root $TemplateName \
	'apt-get update'

qvm-run --auto --pass-io --no-gui --user root $TemplateName \
	'apt-get install google-chrome-stable'


# locale: Cannot set LC_CTYPE to default locale: No such file or directory
qvm-run --auto --pass-io --no-gui --user root $TemplateName 'apt-get install locales locales-all'
# Open Broadcaster Studio (OBS) & VLC & Audacity
qvm-run --auto --pass-io --no-gui --user root $TemplateName 'apt-get install ffmpeg v4l2loopback-dkms vlc audacity obs-studio'
# Disable networking for template
qvm-prefs $TemplateName netvm ''

qvm-shutdown --wait $TemplateName
qvm-create --template=$TemplateName --label=orange $AppVMName
```

## Fedora based (old)
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

