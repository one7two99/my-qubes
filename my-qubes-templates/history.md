#Howto Install

```
#Download ISO from 
https://www.qubes-os.org/doc/installation-guide/

# Verify Download
sha256sum Qubes-R4.0-x86_64.iso
# Burn ISO
sudo dd if=Qubes-R3-x86_64.iso of=/dev/sdX bs=1M && sync


- Run installer and make a full disk installation choosing 9l"make more space available" during setup
- after the reboot part and in part 2  the installation disable "create default application qubes". Takes ~10min


=============
 Basics dom0
=============
# Disable graphical boot in GRUB
sudo sed -i 's/GRUB_TERMINAL_OUTPUT/###GRUB_TERMINAL_OUTPUT/' /etc/default/grub
sudo sed -i '/###GRUB_TERMINAL_OUTPUT/a GRUB_TERMINAL=console' /etc/default/grub
sudo sed -i 's/rhgb quiet/quiet/' /etc/default/grub

GRUB configuration in /etc/default/grub should look like

GRUB_TIMEOUT=5
GRUB_DISTRIBUTOR="$(sed 's, release .*$,,g' /etc/system-release)"
GRUB_DEFAULT=saved
GRUB_DISABLE_SUBMENU=true
GRUB_TERMINAL_OUTPUT="gfxterm"
GRUB_CMDLINE_LINUX="rd.luks.uuid=luks-38e718b4-c059-4b12-aa2b-11d894e474c4 rd.lvm.lv=qubes_dom0/root rd.lvm.lv=qubes_dom0/swap i915.preliminary_hw_support=1 rhgb quiet"
GRUB_CMDLINE_XEN_DEFAULT="console=none dom0_mem=min:1024M dom0_mem=max:4096M iommu=no-igfx"
GRUB_DISABLE_RECOVERY="true"
GRUB_THEME="/boot/grub2/themes/system/theme.txt"
GRUB_DISABLE_OS_PROBER="true"
GRUB_CMDLINE_LINUX="$GRUB_CMDLINE_LINUX rd.qubes.hide_all_usb"

Update Grub

sudo grub2-mkconfig -o /boot/grub2/grub.cfg


# Install tools in dom0
sudo qubes-dom0-update git mc xclip

# install powertop and tlp to optimize battery runtime

qubes-dom0-update tlp powertop

Run the following command on startup

sudo tlp bat && sudo powertop --auto-tune


# Install Fedora minimal template
sudo qubes-dom0-update qubes-template-fedora-30-minimal

# Disable Autostart of Whonix
qvm-prefs --set sys-whonix autostart False

# Fix time manually if needed
# set time in sys-net-vm
qvm-run --auto --user root --pass-io --no-gui sys-net 'sudo date +%T -s "00:30:05"'
# sync time from netvm to dom0
sudo qvm-sync-clock 



=================
 t-fedora-30-sys -> ok
=================

template=fedora-30-minimal
systemplate=t-fedora-30-sys

#remove old template
qvm-kill $systemplate
qvm-remove -f $systemplate

#clone template
qvm-clone $template $systemplate
# update template
qvm-run --auto --user root --pass-io --no-gui $systemplate \
  'dnf update -y'

# Install required packages for Sys-VMs
qvm-run --auto --user root --pass-io --no-gui $systemplate \
  'dnf -y install qubes-core-agent-qrexec qubes-core-agent-systemd \
  qubes-core-agent-networking polkit qubes-core-agent-network-manager \
  notification-daemon qubes-core-agent-dom0-updates qubes-usb-proxy \
  iwl6000g2a-firmware iwl7260-firmware qubes-input-proxy-sender iproute iputils \
  NetworkManager-openvpn NetworkManager-openvpn-gnome \
  NetworkManager-wwan NetworkManager-wifi network-manager-applet'

# Optional packages you might want to install in the sys-template:
qvm-run --auto --user root --pass-io --no-gui $systemplate \
  'dnf -y install nano less pciutils xclip git unzip wget'

qvm-run --auto --user root --pass-io --no-gui $systemplate \
  'dnf -y install qubes-core-agent-passwordless-root'

# Nice(r) Gnome-Terminal compared to xterm
qvm-run --auto --user root --pass-io --no-gui $systemplate \
  'dnf -y install gnome-terminal terminus-fonts dejavu-sans-fonts \
   dejavu-sans-mono-fonts'

# Set new template as template for sys-vms
qvm-shutdown --all --wait --timeout 120
qvm-prefs --set sys-usb template $systemplate
qvm-prefs --set sys-net template $systemplate
qvm-prefs --set sys-firewall template $systemplate
#qvm-prefs --set sys-vpn template $systemplate




==================
 t-fedora-30-apps -> ok
==================

Template=fedora-30-minimal
TemplateName=t-fedora-30-apps
qvm-kill $TemplateName
qvm-remove --force $TemplateName
qvm-start --skip-if-running sys-firewall
qvm-clone $Template $TemplateName
qvm-run --auto --pass-io --no-gui --user root $TemplateName \
  'dnf -y update'

# install a missing package for fedora-29-minimal
# without it, gui-apps will not start
# qvm-run --auto --user root --pass-io --no-gui $systemplate \
#  'dnf install -y e2fsprogs'

qvm-run --auto --pass-io --no-gui --user root $TemplateName \
  'dnf install -y emacs keepass klavaro libreoffice gedit gimp \
  firefox qubes-usb-proxy pulseaudio-qubes nano git transmission mc \
  transmission-cli less qubes-gpg-split qubes-core-agent-networking unzip \
  nautilus wget qubes-core-agent-nautilus gnome-terminal-nautilus evince \
  polkit e2fsprogs gnome-terminal terminus-fonts dejavu-sans-fonts \
  dejavu-sans-mono-fonts xclip pinentry-gtk \
  evince-nautilus nautilus-sendto nautilus-pastebin nautilus-search-tool'

qvm-shutdown --wait $TemplateName

# set App-template as defaut template
qubes-prefs --set default_template $TemplateName



==========
 Vault-VM -> ok
==========

template=t-fedora-30-apps
appvm=my-vault

qvm-shutdown --wait $appvm
qvm-create --template=$template --label=black $appvm
qvm-prefs --set $appvm template $template

# Hint: install pinentry-gtk in template VM
echo "pinentry-program /usr/bin/pinentry-gtk" > ~/.gnupg/gpg-agent.conf
gpg-connect-agent reloadagent /bye



# Disable networking
qvm-prefs --set $appvm netvm ""

# To allow access to Vault-VM without user-dialog:
nano /etc/qubes-rpc/policy/qubes.Gpg

#add:
my-untrusted my-vault allow
$anyvm $anyvm ask

#Configure Vault-VM in the AppVMs
sudo bash
echo "my-vault" > /rw/config/gpg-split-domain


===================
 t-fedora-29-media -> ok
===================


Template=fedora-30-minimal
TemplateName=t-fedora-30-media
AppVMName=my-media
qvm-kill $TemplateName
qvm-remove --force $TemplateName
#qvm-start --skip-if-running sys-firewall
qvm-clone $Template $TemplateName
qvm-run --auto --pass-io --no-gui --user root $TemplateName \
  'dnf -y update'

qvm-run --auto --pass-io --no-gui --user root $TemplateName \
  'dnf install -y pulseaudio-qubes qubes-core-agent-networking e2fsprogs'

# Install Google Chrome
qvm-run --pass-io --no-gui --user root $TemplateName \
  'dnf install -y fedora-workstation-repositories && \
   dnf config-manager --set-enabled google-chrome && \
   dnf install -y google-chrome-stable'

qvm-shutdown --wait $TemplateName

qvm-create --template=$TemplateName --label=orange $AppVMName


===============
 Disposable VM -> ok
===============

# Create a new Disposable App-VM which is based on a custom template t-fedora-2
template4dvm=t-fedora-29-apps
newdvmtemplatename=my-dvm
qvm-create --template $template4dvm --label red --property template_for_dispvms=True --class=AppVM $newdvmtemplatename
 
# Fix menu entry from Domain: my-dvm to Disposable: my-dvm
# https://groups.google.com/forum/#!msg/qubes-users/gfBfqTNzUIg/sbPp-pyiCAAJ
# https://github.com/QubesOS/qubes-issues/issues/1339#issuecomment-338813581
qvm-features $newdvmtemplatename appmenus-dispvm 1
qvm-sync-appmenus --regenerate-only $newdvmtemplatename

# Set default DispVM for qubes
qubes-prefs --set default_dispvm $newdvmtemplatename

###usefull commands
# remove old dvm, change all references to this VM before in the Qubes settings
qvm-prefs fedora-26 installed_by_rpm false
qvm-remove fedora-26

# Change the Disp-VM from an AppVM (here: my-untrusted)
appvmname=my-untrusted
qvm-prefs --set $appvmname default_dispvm $newdvmtemplatename
 
# Try to start something from this AppVM in a disposable VM
qvm-run --auto $appvmname 'qvm-open-in-dvm https:/google.de'

# This should start a new dispvm which is based on your dvm-App
# Check the template on which the dispvm is based on in dom0
qvm-ls | grep disp





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
  'dnf install -y emacs keepass libreoffice gedit gimp gnome-terminal firefox \
  nano git mc terminus-fonts less unzip dejavu-sans-fonts pinentry-gtk \
  qubes-gpg-split qubes-core-agent-networking qubes-usb-proxy pulseaudio-qubes \
  gstreamer gstreamer-plugins-base libffi libpng12 libXScrnSaver libsigc++20 \
  pangox-compat xclip iputils iproute \
  # qubes-core-agent-qrexec qubes-core-agent-systemd polkit notification-daemon qubes-input-proxy-sender'

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



==================
 t-fedora-29-mail -> ok
==================

--- 8< ---
Template=fedora-30-minimal
TemplateName=t-fedora-30-mail
qvm-kill $TemplateName
qvm-remove --force $TemplateName
qvm-clone $Template $TemplateName

qvm-run --auto --pass-io --no-gui --user root $TemplateName \
  'dnf -y update'

# install a missing package for fedora-29-minimal
# without it, gui-apps will not start
qvm-run --auto --user root --pass-io --no-gui $TemplateName \
  'dnf install -y e2fsprogs'

qvm-run --auto --pass-io --no-gui --user root $TemplateName \
  'dnf install -y gnome-terminal qubes-usb-proxy nano mc terminus-fonts \
  less dejavu-sans-fonts dejavu-sans-mono-fonts \ 
  qubes-gpg-split qubes-core-agent-networking unzip mlocate screen w3m qutebrowser mupdf \
  vdirsyncer java-11-openjdk dnf-plugins-core polkit pinentry-gtk \
  thunderbird thunderbird-qubes thunderbird-enigmail unzip xclip'

# Install Offlineimap and Neomutt
qvm-run --auto --pass-io --no-gui --user root $TemplateName \
  'dnf copr enable flatcap/neomutt && \
  dnf -y install neomutt offlineimap git notmuch cyrus-sasl-plain'

# make sure to enable java-11-openjdk
qvm-run --auto --pass-io --no-gui --user root $TemplateName \
  "xterm -hold -e 'alternatives --config java'"

# --- to connect to exchange ---
# Download davmail.zip from the website
# qvm-move the zipfile to your mail-AppVM-template 

DownloadVM=my-untrusted
qvm-run --auto --pass-io --no-gui --user root $TemplateName \
  "mkdir -p /opt/davmail && \
   unzip /home/user/QubesIncoming/$DownloadVM/davmail-*.zip -d /opt/davmail"
# ------------------------------

qvm-shutdown $TemplateName 

qvm-create --template=$TemplateName --label=blue my-bizmail
qvm-create --template=$TemplateName --label=blue my-privmail


### Thunderbird
Download Hide Local Folders



=====================
 t-fedora-30-storage -> ok
=====================

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
   qubes-usb-proxy mlocate qubes-core-agent-networking'

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
# Login/Configure Nextcloud-Client (you need to login via Browser, this can be done in another AppVM)
# Hint: Add an App-Password/Token

==============================================================================
==============================================================================


=====================
 Storage AppVM (old)
=====================

basetemplate=fedora-29-minimal
StorageTemplateVM=t-fedora-29-storage
    qvm-clone $basetemplate $StorageTemplateVM
    # Enable networking
    qvm-prefs --set $StorageTemplateVM netvm sys-firewall


    qvm-clone $basetemplate $StorageTemplateVM
    # Enable networking
    qvm-prefs --set $StorageTemplateVM netvm sys-firewall
    # Launch image, install updated and enable networking for the template.
    qvm-run --auto --user root --pass-io --no-gui $StorageTemplateVM '\
       dnf -y update && \
       dnf -y install qubes-core-agent-networking e2fsprogs && \
       shutdown -h now'
    # Install general packages
    qvm-run --auto --user root --pass-io --no-gui $StorageTemplateVM '\
        dnf -y install sshfs encfs openssh-server nano gnome-terminal'

    qvm-shutdown --wait $StorageTemplateVM

    # Install OneDrive
#    qvm-run --auto --user root --pass-io --no-gui $StorageTemplateVM '\
#       dnf -y install git libcurl-devel sqlite-devel xz make automake gcc gcc-c++ kernel-devel && \
#       curl -fsS https://dlang.org/install.sh | bash -s dmd && \
#       source ~/dlang/dmd-*/activate && \
#       git clone https://github.com/skilion/onedrive.git && \
#       cd onedrive && make && sudo make install'

    # Packages for CryFS
    # https://github.com/cryfs/cryfs/blob/develop/README.md
#   qvm-run --auto --user root --pass-io --no-gui $StorageTemplateVM '\
#       dnf -y install git gcc-c++ cmake make libcurl-devel boost-devel boost-static openssl-devel fuse-devel python'
#    qvm-run --auto --user root --pass-io --no-gui $StorageTemplateVM '\
#       git clone https://github.com/cryfs/cryfs.git cryfs && \
#       cd cryfs && mkdir cmake && cd cmake && cmake .. && make && make install'
   



======
 win7
======

qvm-create win7 --class StandaloneVM --property virt_mode=hvm --property kernel="" --property memory=4096 --property maxmem=4096 --property debug=True --label=blue 
qvm-features win7 video-model cirrus

sudo qubes-dom0-update --enablerepo=qubes-dom0-current-testing qubes-windows-tools
qvm-run --pass-io my-untrusted 'cat /tmp/mozilla_user0/qubes-windows-tools-3.2.2-3.x86_64.rpm' > qubes-windows-tools-3.2.2-3.x86_64.rpm
rpm -K qubes-windows-tools-3.2.2-3.x86_64.rpm 
sudo rpm -ivh qubes-windows-tools-3.2.2-3.x86_64.rpm 
sudo updatedb
locate windows-tools
ls -lah /usr/lib/qubes/qubes-windows-tools*
qvm-prefs --set win7 qrexec_timeout 300
qvm-start win7 --install-windows-tools
qvm-backup --verbose --save-profile win7 --encrypt --compress --dest-vm my-backup /home/user/backup win7
qvm-prefs --set win7 debug True
qvm-prefs --set win7 debug False
```
