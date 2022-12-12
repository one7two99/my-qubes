# Open all Links from an AppVM in a disposable VM

This can be accomplished by changing the "default browser" of this AppVM to the Open-in-DispVM command
```
# in AppVM check the current fefault Browser
xdg-settings get default-web-browser
# Change default browser to run the "Open in DVM"-command
xdg-settings set default-web-browser qvm-open-in-dvm.desktop
# Verifiy new setting
xdg-settings get default-web-browser
```

Flatpak
=======

In order to installfew special Apps only in AppVMs I'm using flatpak and install those apps in the user-space.
(!) make sure that your AppVM has enough private disk storage, as flatpaks need some space.

In the AppVM run
```
flatpak --user remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpak.repo
flatpak --user search <APPNAME>
flatpak --user install <APPNAME>

