PIM (Personal Information Management) Template
==============================================

```
AppVMName=my-pim
TemplateName=t_fedora-37-apps_v1

qvm-create --template $TemplateName --label blue --class=AppVM $AppVMName

qvm-run --auto --pass-io --no-gui --user root $AppVMName \
  'flatpak remote-add --user --verbose --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo \
   flatpak install --user --verbose flathub net.cozic.joplin_desktop'
```
