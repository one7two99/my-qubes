#!/bin/bash
# update-all.sh - Update all Template-VMs

# Update dom0
sudo qubes-dom0-update


# Update all Fedora templates
echo "[ Updating Fedora Templates ]"
for i in `qvm-ls | grep Template | grep t-fedora | gawk '{ print $1 }'`;
  do
    echo
    echo "Updating $i ..."
    qvm-run --auto --user root --pass-io $i 'dnf -y update';
    qvm-shutdown $i;
    echo "... done."
done


# Update all Debian Templates
echo "[ Updating Debian Templates ]"
for i in `qvm-ls | grep Template | grep t-debian | gawk '{ print $1 }'`; 
  do
    echo
    echo "Updatung $i ..."
    qvm-run --auto --user root --pass-io $i 'apt-get update && apt-get -y upgrade';
    qvm-shutdown $i;
    echo "... done."
done

# Update Whonix
#qvm-run --auto --user root --pass-io --no-gui whonix-gw-14 'apt-get -y update' && qvm-shutdown whonix-gw-14
#qvm-run --auto --user root --pass-io --no-gui whonix-ws-14 'apt-get -y update' && qvm-shutdown whonix-ws-14

# Update Whonix Templates
echo "[ Updating Whonix Templates ]"
for i in `qvm-ls | grep Template | grep whonix | gawk '{ print $1 }'`; 
  do
    echo
    echo "Updatung $i ..."
    qvm-run --auto --user root --pass-io  $i 'apt-get update && apt-get -y upgrade';
    qvm-shutdown $i;
    echo "... done."
done

