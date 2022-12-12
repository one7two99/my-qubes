==========
 Vault-VM -> ok
==========

template=t-fedora-33-apps
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

