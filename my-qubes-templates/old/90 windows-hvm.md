```
qvm-create win7new --hvm --label red
qvm-prefs -s win7new memory 4096
qvm-prefs -s win7new maxmem 4096
qvm-grow-root win7new 25g 
qvm-prefs -s win7new debug true
cp /var/lib/qubes/appvms/win7new/win7new.conf /tmp
sed -i "s/<model \+type='xen' \+vram=/<model type='cirrus' vram=/" /tmp/win7new.conf
qvm-start --custom-config=/tmp/win7new.conf --cdrom=untrusted:/home/user/windows_install.iso win7new
# restart after the first part of the windows installation process ends
qvm-start --custom-config=/tmp/win7new.conf win7new
# once Windows is installed and working
qvm-prefs -s win7new memory 2048
qvm-prefs -s win7new maxmem 2048
rm /tmp/win7new.conf
qvm-prefs -s win7new qrexec_timeout 300

# Disable User Authentification
control userpasswords2

# Get IPs
qvm-prefs my-win7 visible_ip
qvm-prefs sys-firewall visible_ip
qvm-run --pass-io sys-firewall "cat /etc/resolv.conf"

bcedit /set testsigning on
# reboot

qvm-start --cdrom=dom0:/home/philipp/qubes-windows-tools/qubes-windows-tools.iso my-win7

# Install Qubes Windows Tools
# Disable Qubes Network Service via msconfig

# Disable Debug Mode
qvm-prefs --set my-win7 debug False

# Toggle Seamless Mode
echo SEAMLESS | qvm-run -p --service my-win7 qubes.SetGuiMode
echo FULLSCREEN | qvm-run -p --service my-win7 qubes.SetGuiMode
```
