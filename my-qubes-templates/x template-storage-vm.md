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
