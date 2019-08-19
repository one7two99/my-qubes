#!/bin/bash
# qubes-datastore.sh
# shared datastore between AppVMs
# $1 = command

# Name of TemplateVM
StorageTemplateVM=t-fedora-28-storage
# Name of AppVMs
my_storage_access=my-storage-access
my_storage_datastore=my-storage-datastore
#additional variables
sshfs_share=/home/user/my-share            # path to data on sshserver
sshfs_mountdir=/home/user/my-share         # local mount point
encfs_share=/home/user/my-share/ENCFS      # folder with encfs-data
encfs_mountdir=/home/user/my-share.plain   # where to mount plain-text

case "$1" in
  'create-template')
    # In dom0: Clone fedora 28 Template to a new template 't-storage'
    echo "Create Template..."
    qvm-clone fedora-28-minimal $StorageTemplateVM
    # Enable networking
    qvm-prefs --set $StorageTemplateVM netvm sys-firewall
    # Launch image, install updated and enable networking for the template.
    echo "Install Updates..."
    qvm-run --auto --user root $StorageTemplateVM "xterm -hold -e '\
       dnf -y update && \
       dnf -y install qubes-core-agent-networking && \
       shutdown -h now'"
    # Install general packages
    echo "Install general packages..."
    qvm-run --auto --user root $StorageTemplateVM "xterm -hold -e '\
        dnf -y install sshfs encfs openssh-server nano gnome-terminal && \
        echo ... DONE (one7two99).'"
    # Install OneDrive
#    echo "Install OneDrive..."
#    qvm-run --auto --user root $StorageTemplateVM "xterm -hold -e '\
#       dnf -y install git libcurl-devel sqlite-devel xz make automake gcc gcc-c++ kernel-devel && \
#       curl -fsS https://dlang.org/install.sh | bash -s dmd && \
#       source ~/dlang/dmd-*/activate && \
#       git clone https://github.com/skilion/onedrive.git && \
#       cd onedrive && make && sudo make install && \
#       echo ... DONE (one7two99).'"
    # Packages for CryFS
###    echo "Install CryFS..."
    # https://github.com/cryfs/cryfs/blob/develop/README.md
#   qvm-run --auto --user root $StorageTemplateVM "xterm -hold -e '\
#       dnf -y install git gcc-c++ cmake make libcurl-devel boost-devel boost-static openssl-devel fuse-devel python'"
#    qvm-run --auto --user root $StorageTemplateVM "xterm -hold -e '\
#       git clone https://github.com/cryfs/cryfs.git cryfs && \
#       cd cryfs && mkdir cmake && cd cmake && cmake .. && make && make install && \
#       echo ... DONE (one7two99).'"
    ;;

  'remove-template')
    ## remove AppVMs
    qvm-kill $StorageTemplateVM
    qvm-remove -f $StorageTemplateVM
    ;;

  'enable-sharing')
    # Launch AppVMs
    qvm-start --skip-if-running $my_storage_access $my_storage_datastore
    # get IPs of the AppVMs
    my_storage_access_ip=`qvm-ls --format network | grep $my_storage_access | gawk '{ print $4 }'`
    my_storage_datastore_ip=`qvm-ls --format network | grep $my_storage_datastore | gawk '{ print $4 }'`

    # Add firewall rules and enable sshd in datastore VM
    #allow access from acces vm to datastore
    qvm-run --auto --user root sys-firewall \
      "iptables -I FORWARD 1 -p tcp -s $my_storage_access_ip -d $my_storage_datastore_ip --dport ssh -j ACCEPT"
    # firewall rules in datastore and enable ssh server
    qvm-run --auto --user root $my_storage_datastore \
      "iptables --flush && iptables --policy INPUT DROP && iptables --policy OUTPUT DROP && iptables --policy FORWARD DROP && \
      systemctl start sshd.service && \
      iptables -I INPUT 1 -p tcp -s $my_storage_access_ip -d $my_storage_datastore_ip --dport ssh -m state --state NEW,ESTABLISHED -j ACCEPT && \
      iptables -I OUTPUT 1 -p tcp -s $my_storage_datastore_ip --sport ssh -d $my_storage_access_ip -m state --state ESTABLISHED -j ACCEPT"
    # firewall rules in access vm
    qvm-run --auto --user root $my_storage_access \
      "iptables --flush && iptables --policy INPUT DROP && iptables --policy OUTPUT DROP && iptables --policy FORWARD DROP && \
      iptables -I INPUT 1 -p tcp -s $my_storage_datastore_ip --sport ssh -d $my_storage_access_ip  -m state --state ESTABLISHED -j ACCEPT && \
      iptables -I OUTPUT 1 -p tcp -s $my_storage_access_ip -d $my_storage_datastore_ip --dport ssh -m state --state NEW,ESTABLISHED -j ACCEPT"
    ;;

  'create-appvms')
    # create AppVMs
    qvm-create --template $StorageTemplateVM --label blue $my_storage_datastore
    qvm-create --template $StorageTemplateVM --label blue $my_storage_access

    $0 enable-sharing

    # get IPs of the AppVMs
    my_storage_access_ip=`qvm-ls --format network | grep $my_storage_access | gawk '{ print $4 }'`
    my_storage_datastore_ip=`qvm-ls --format network | grep $my_storage_datastore | gawk '{ print $4 }'`

    ### Configure VMs and sshfs
    # setup datastore VM, creating directory for fileshare and .ssh-dir
    qvm-run --auto $my_storage_datastore \
      "mkdir -p $sshfs_share $encfs_share /home/user/.ssh && \
      chmod 700 /home/user/.ssh"
    ### setup access VM
    # create ssh-keypair
    qvm-run --auto $my_storage_access "ssh-keygen -P '' -f /home/user/.ssh/id_rsa"
    qvm-run --auto $my_storage_access "mkdir -p $sshfs_mountdir $encfs_mountdir"
    # exchange key
    qvm-run --pass-io $my_storage_access "cat /home/user/.ssh/id_rsa.pub" | \
      qvm-run --pass-io $my_storage_datastore "cat > /home/user/.ssh/authorized_keys"
    #qvm-run --auto $my_storage_access "sshfs user@$my_storage_datastore:$sshfs_share $sshfs_mountdir"
    # fix permissions on authorized_keys
    qvm-run $my_storage_datastore "chmod 600 /home/user/.ssh/authorized_keys"
    # set datastore as allowed host in access VM
    qvm-run --pass-io $my_storage_datastore 'ssh-keyscan localhost 2>/dev/null' | grep ecdsa | \
      sed "s/localhost/$my_storage_datastore_ip/" | qvm-run --pass-io $my_storage_access 'cat > /home/user/.ssh/known_hosts'
    # fix permissions on known hosts
    qvm-run $my_storage_access "chmod 644 /home/user/.ssh/known_hosts"
    ;;

  'mount')
    # Launch AppVMs
    qvm-start --skip-if-running $my_storage_access $my_storage_datastore
    # get IPs of the AppVMs
    my_storage_access_ip=`qvm-ls --format network | grep $my_storage_access | gawk '{ print $4 }'`
    my_storage_datastore_ip=`qvm-ls --format network | grep $my_storage_datastore | gawk '{ print $4 }'`

    $0 enable-sharing
    # Add Firewall Rules
    # Enable sshd in datastore VM 
    # mount datastore 
    qvm-run --auto my-storage-access "sshfs user@$my_storage_datastore_ip:$sshfs_share $sshfs_mountdir"
    # mount encfs share
    qvm-run --auto my-storage-access "xterm -e 'encfs $encfs_share $encfs_mountdir'"
    ;;

  'unmount')
    # unmount encfs share
    qvm-run --auto my-storage-access "fusermount -u $encfs_mountdir"
    # unmount datastore 
    qvm-run --auto my-storage-access "fusermount -u $sshfs_mountdir"
    # Remove Firewall Rules in sys-firewall
    # Disable sshd in datastore VM
    ;;

  'remove-appvms')
    ## remove AppVMs
    qvm-kill $my_storage_datastore $my_storage_access
    qvm-remove -f $my_storage_datastore $my_storage_access
    ;;

  *)
    # general help
    echo
    echo "Usage $0 <command>"
    echo
    echo "valid commands:"
    echo
    echo "  mount             : mount datastore"
    echo "  unmount           : unmount datastore"
    echo
    echo "  create-template   : Create new template"
    echo "  remove-template   : Delete template"
    echo "  create-appvms     : Create AppVMs based on the storage-template"
    echo "  remove-appvms     : Delete AppVMs"
    echo
    exit 1
esac
