```
# my-telegram
# AppVM based on t_fedora-36-apps
# Install Telegram via flatpak

flatpak --user search telegram
flatpak --user remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak --user install org.telegram.desktop

