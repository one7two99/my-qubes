# NextCloud Template
Status: testing

Doesn't work after reboot of AppVM, as credentials needs to be entered again but sync will not start.
During initial boot everything works.

``` 
Template=fedora-30-minimal
TemplateName=t-fedora-30-storage

# Remove an existing template
if [ -d /var/lib/qubes/vm-templates/$TemplateName ];
   then qvm-kill $TemplateName;
   qvm-remove --force $TemplateName;
fi

qvm-clone $Template $TemplateName

qvm-run --auto --pass-io --no-gui --user root $TemplateName \
  'dnf -y update'

# mandatory: install Nextcloud + Qubes Basics
qvm-run --auto --pass-io --no-gui --user root $TemplateName \
  'dnf -y install nextcloud-client nautilus qubes-core-agent-nautilus \
   qubes-usb-proxy mlocate qubes-core-agent-networking gnome-keyring'

# optional: Some more usefull tools
qvm-run --auto --pass-io --no-gui --user root $TemplateName \
  'dnf -y install nano mc less unzip'

# optional: Nice(r) (Gnome-)Terminal
qvm-run --auto --pass-io --no-gui --user root $TemplateName \
  'dnf -y install gnome-terminal qubes-usb-proxy terminus-fonts \
   dejavu-sans-fonts dejavu-sans-mono-fonts'

qvm-shutdown $TemplateName

qvm-create --template=$TemplateName --label=blue my-nextcloud

# add Nextcloud-Sync-Client to Qubes Menu
# Login/Configure Nextcloud-Client (you need to login via Browser, this
can be done in another AppVM)
# Hint: Add an App-Password/Token
```
