# AppVM for messengers using Flatpak
This VM is based on my general AppVM template (t_fedora-36-apps) and installes additional applications as flatpaks in the user space.

Before installing flatpaks, you need to add a flatpak repository
```
flatpak --user remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
```

## Telegram
```
flatpak --user install flathub org.telegram.desktop

# Run Telegram
flatpak run org.telegram.desktop
```

## Signal
This flatpak will also try to install org.freedesktop.Platform.openh264 and needs access to...
ciscobinary.openh264.org
*.rackcdn.com
... which might be blocked by some DNS-blocklists. I 
I have choosen to run Signal without this package.
```
flatpak --user intsall flathub org.signal.Signal

# Run Signal
flatpak run org.signal.Signal
```
