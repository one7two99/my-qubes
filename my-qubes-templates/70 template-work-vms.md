================== 
 t-fedora-28-work -> ok
================== 
basetemplate=fedora-30-minimal
worktemplatevm=t-fedora-30-work
DownloadAppVM=my-media
WorkAppVM=my-globits

#templatevm=t-fedora-29-work

# Remove an existing template
if [ -d /var/lib/qubes/vm-templates/$worktemplatevm ];
   then qvm-kill $worktemplatevm;
   qvm-remove --force $worktemplatevm;
fi
qvm-clone $basetemplate $worktemplatevm

# Install Updates
qvm-run --auto --user root --pass-io --no-gui $worktemplatevm \
  'dnf -y update'

qvm-run --auto --user root --pass-io --no-gui $worktemplatevm \
  'dnf install -y emacs keepass libreoffice gedit gimp gnome-terminal \
  firefox nano git mc terminus-fonts less unzip dejavu-sans-fonts \
  pinentry-gtk qubes-gpg-split qubes-core-agent-networking \
  qubes-usb-proxy pulseaudio-qubes gstreamer gstreamer-plugins-base \
  libffi libpng12 libXScrnSaver libsigc++20 pangox-compat \
  xclip iputils iproute \
  qubes-core-agent-qrexec qubes-core-agent-systemd polkit \
  notification-daemon qubes-input-proxy-sender'

### AnyConnect VPN - OpenConnect
qvm-run --auto --pass-io --no-gui --user root $worktemplatevm \
 'dnf -y install NetworkManager-openconnect network-manager-applet qubes-core-agent-network-manager \
  NetworkManager-openconnect-gnome NetworkManager-vpnc-gnome NetworkManager-openvpn-gnome NetworkManager-openvpn'

### Install Flash
# Download Flash (Info: NPAPI is for Firefox // PPAPI is for Chrome)
https://get.adobe.com/de/flashplayer/otherversions/
Download: Linux (64-bit) (rpm) - NPAPI
# Transfer Flash to template
qvm-run --auto --pass-io $DownloadAppVM 'cat Downloads/flash-player*.rpm' | \
  qvm-run --pass-io $worktemplatevm 'cat > /home/user/flash-player.rpm'
# Install Flash package
qvm-run --auto --pass-io --no-gui --user root $worktemplatevm \
  'rpm --install /home/user/flash-player.rpm' 

qvm-shutdown --wait $worktemplatevm 

# VMware Horizon View
# Download Horizon Client in an AppVM and transfer it to the work template
# https://my.vmware.com/web/vmware/details?downloadGroup=CART19FQ4_LIN64_410&productId=578
qvm-run --auto --pass-io $DownloadAppVM 'cat Downloads/VMware*.bundle' | \
  qvm-run --pass-io $worktemplatevm 'cat > /home/user/horizon-client.bundle'
qvm-run --pass-io --no-gui --user root $worktemplatevm \
   'chmod +x /home/user/horizon-client.bundle && \
   /home/user/horizon-client.bundle'

# Update AppMenus  in dom0:
qvm-sync-appmenus $worktemplatevm

### Create AppVM
qvm-shutdown --wait $worktemplatevm
qvm-create --template=$worktemplatevm --label=blue $WorkAppVM

# Add network-manager to Qubes Settings > Services
qvm-service --enable $WorkAppVM network-manager

# Add Openconnect VPN
# Network Manager Icon > VPN Connections > Configure VPN
# Add > Cisco AnyConnect Compatible VPN (openconnect)


