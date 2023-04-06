t_debian-11-mail_v1
===================

```
Template=debian-11-minimal
TemplateName=t_debian-11-mail_v1
qvm-clone $Template $TemplateName 
qvm-run --auto --pass-io --no-gui --user root $TemplateName 'apt get update'
qvm-run --auto --pass-io --no-gui --user root $TemplateName 'dpkg-reconfigure locales'
qvm-run --auto --pass-io --no-gui --user root $TemplateName 'apt-get upgrade'
qvm-run --auto --pass-io --no-gui --user root $TemplateName \
   'apt-get install nano git qubes-usb-proxy qubes-gpg-split \
    qubes-core-agent-networking pinentry-gtk dnsutils iptraf-ng \
    zenity thunderbird thunderbird-qubes'
qvm-run --auto --pass-io --no-gui --user root $TemplateName \
   'apt-get install nano git qubes-usb-proxy qubes-gpg-split \
    qubes-core-agent-networking  dnsutils iptraf-ng zenity \
    thunderbird thunderbird-qubes'
    
# Download ProtonmailBridge and copy it to the TemplateVM
qvm-run --auto --pass-io --no-gui --user root $TemplateName 'dpkg -i /home/user/QubesIncoming/*/protonmail-bridge*.deb'
qvm-run --auto --pass-io --no-gui --user root $TemplateName 'apt --fix-broken install'
qvm-run --auto --pass-io --no-gui --user root $TemplateName 'dpkg -i /home/user/QubesIncoming/*/protonmail-bridge*.deb'
qvm-shutdown $TemplateName 
MailAppVM=my-mail
qvm-create --template=$TemplateName --label=blue $MailAppVM 

```


t-fedora-37-mail
=================

Running ProtonmailBridge in an AppVm based on fedora didn't work, therefore I used a debian based template (as stated above)
```
Template=fedora-33-minimal
TemplateName=t-fedora-33-mail
qvm-kill $TemplateName
qvm-remove --force $TemplateName
qvm-clone $Template $TemplateName

qvm-run --auto --pass-io --no-gui --user root $TemplateName \
  'dnf -y update'

qvm-run --auto --pass-io --no-gui --user root $TemplateName \
  'dnf install -y  nano git \
  qubes-usb-proxy qubes-gpg-split qubes-core-agent-networking \
  pinentry-gtk dnsutils iptraf-ng nano git zenity \
  thunderbird thunderbird-qubes'

# installed before in fedora-36 based template: dnf-plugins-core polkit 

# Install Protonmail Bridge
# Download ProtonBridge in a disposable VM
# https://proton.me/mail/bridge#download and choose the .rpm-package
# Copy rpm-package from disposable VM to the mail-template VM
qvm-run --auto --pass-io --no-gui --user root $TemplateName \
  'dnf install -y /home/user/QubesIncoming/*/protonmail-bridge*.rpm'

qvm-shutdown $TemplateName 

# Create your mail AppVM
MailAppVM=my-mail
qvm-create --template=$TemplateName --label=blue $MailAppVM

# Allow only communication to Protonmail-Servers
qvm-firewall $MailAppVM reset
qvm-firewall $MailAppVM del --rule-no 0
ProtonmailIPs="185.70.42.12 185.70.42.25"
for IP in $ProtonmailIPs
do
   qvm-firewall $MailAppVM add action=accept proto=tcp dsthost=$IP/32 dstports=443 comment="Allow ProtonmailBridge"
done
qvm-firewall $MailAppVM add action=drop comment="Drop everything else"
