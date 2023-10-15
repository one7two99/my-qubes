t_debian-12-mail_v1
===================
```
Template=debian-12-minimal
TemplateName=t_debian-12-mail_v1
qvm-clone $Template $TemplateName

# Conigure locales
qvm-run --auto --user root --pass-io --no-gui $TemplateName 'sudo apt-get -y install dialog'

# Conigure locales
qvm-run --auto --user root --pass-io --no-gui $TemplateName 'dpkg-reconfigure locales'
# install the following locales: 72,97
# 72 = de_DE.UTF-8
# 97 = en_US.UTF-8 <- set this as default !

 qvm-run --auto --pass-io --no-gui --user root $TemplateName 'apt-get update && apt-get upgrade'
qvm-run --auto --pass-io --no-gui --user root $TemplateName \
   'apt-get install nano git qubes-usb-proxy qubes-gpg-split \
    qubes-core-agent-networking dnsutils iptraf-ng \
    zenity thunderbird thunderbird-qubes pinentry-gtk2 \
    evolution evolution-ews nautilus'
 
# Download ProtonmailBridge and copy it to the TemplateVM
DownloadVM=my-work

# Transfer .deb-package to the template-VM
qvm-run --auto --pass-io --no-gui --user root $DownloadVM \
	'cat /home/user/Downloads/protonmail*' \
	| qvm-run	--auto --pass-io --no-gui --user root $TemplateName \
		'cat - > /home/user/protonmail-bridge.deb'
# Remove the downloaded .deb-file
qvm-run --auto --pass-io --no-gui --user root $TemplateName \
                'rm /home/user/protonmail-bridge.deb'
# Install Protonmail-Bridge
qvm-run	--auto --pass-io --no-gui --user root $TemplateName \
                'apt-get install /home/user/protonmail-bridge.deb'

# missing packages for protonbridge in AppVM
qvm-run --auto --pass-io --no-gui --user root $TemplateName \
	"apt-get install -y \
		libopengl0 pass libxcb-shape0 libxcb-render-util0 \
		libxcb-image0  libxcb-icccm4  libxcb-keysyms1"
#to setup pass:
qvm-run --auto --pass-io --no-gui --user root $TemplateName \
        "rm -Rf /home/user/.gnupg /home/user/.password-store"
#Create keys with empty password with User Protonmail no@mail.com
qvm-run --auto --pass-io --no-gui $TemplateName xterm
# run two commands
gpg --full-generate-key
pass init no@mail.com
gpg --list-keys

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
```
