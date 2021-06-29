===============
 Disposable VM -> ok
===============

# Create a new Disposable App-VM which is based on a custom template t-fedora-2
template4dvm=t-fedora-33-apps
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


#Start an App in a DispVM from dom0
qvm-run --dispvm=<DISPVM> --service qubes.StartApp+<COMMAND>



