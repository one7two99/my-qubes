t_fedora-34-work_v1
===================
```
basetemplate=fedora-37-minimal
worktemplatevm=t_fedora-37-work_v1
DownloadAppVM=my-media
WorkAppVM=my-work

# Remove an existing template
if [ -d /var/lib/qubes/vm-templates/$worktemplatevm ];
   then qvm-kill $worktemplatevm;
   qvm-remove --force $worktemplatevm;
fi

# Clone Template
qvm-clone $basetemplate $worktemplatevm

# Install Updates
qvm-run --auto --user root --pass-io --no-gui $worktemplatevm \
  'dnf -y update'

# Install Applications
qvm-run --auto --user root --pass-io --no-gui $worktemplatevm \
	'dnf install -y \
		gedit \
		nano \
		git \
		mc \
		less \
		unzip \
		pinentry-gtk \
		qubes-gpg-split \
		qubes-core-agent-networking \
		qubes-usb-proxy \
		libffi \
		libpng12 \
		libXScrnSaver \
		libsigc++20 \
		iputils \
		iproute \
		qubes-core-agent-qrexec \
		qubes-core-agent-systemd \
		notification-daemon \
		qubes-input-proxy-sender \
		zypper \
		zenity'

#old
		pulseaudio-qubes \
		gstreamer \
		gstreamer-plugins-base \
		pangox-compat \

# Slack
# Download: https://slack.com/downloads/instructions/fedora
qvm-run --auto --pass-io --no-gui --user root $worktemplatevm \
	'dnf -y install libappindicator-gtk3'
qvm-run --auto --pass-io --no-gui --user root $worktemplatevm \
	'rpm -i /home/user/QubesIncoming/*/slack*'

# Teams
qvm-prefs $worktemplatevm  netvm sys-firewall
qvm-run --auto --pass-io --no-gui --user root $worktemplatevm \
	'rpm --import https://packages.microsoft.com/keys/microsoft.asc'
qvm-run --auto --pass-io --no-gui --user root $worktemplatevm \
	'rpm -i /home/user/QubesIncoming/*/teams*'

# Zoom
qvm-run --auto --pass-io --no-gui --user root $worktemplatevm \
	'dnf install ibus ibus-m17n libxkbcommon-x11 mesa-dri-drivers'
qvm-run --auto --pass-io --no-gui --user root $worktemplatevm \
	'rpm -i /home/user/QubesIncoming/*/zoom*'

# WebEx
qvm-run --auto --pass-io --no-gui --user root $worktemplatevm \
        'dnf install lshw upower'
qvm-run --auto --pass-io --no-gui --user root $worktemplatevm \
	'rpm -i /home/user/QubesIncoming/*/Webex*'

# Horizon View
qvm-run --pass-io --no-gui --user root $worktemplatevm \
	'chmod +x /home/user/QubesIncoming/*/VMware* && \
	/home/user/QubesIncoming/*/VMware*'
# Install Real-Time Audio-Video

### AnyConnect VPN - OpenConnect
qvm-run --auto --pass-io --no-gui --user root $worktemplatevm \
	'dnf -y install \
		NetworkManager-openconnect \
		network-manager-applet \
		qubes-core-agent-network-manager \
		NetworkManager-openconnect-gnome \
		NetworkManager-vpnc-gnome \
		NetworkManager-openvpn-gnome \
		NetworkManager-openvpn'


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
```
