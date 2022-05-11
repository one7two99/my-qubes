# How to connect to Microsoft Exchange with Qubes OS

## Introduction
This Howto describes how you can connect to your Exchange Server with Qubes OS.
It is based on using a Exchange-to-IMAP-Gateway which is named Davmail.

The howto covers:

- Installation/Configuration of Davmail
- Configuration to use Thunderbird
- Configuration to use neomutt
- Configuration to use khard and khal

the following VMs will be mentioned in this howto:

- t-mail = TemplateVM
- my-vault = ApppVM which is used for SplitGPG
- my-workmail = AppVM

TODO:

- Howto use SplitGPG with neomutt
- Howto work with attachments (PDF/Pictures) and HTML mails in neomutt

## Davmail

dnf install java-9-openjdk
dnf install system-switch-java

install required packages for Davmail
```
sudo dnf install java-9-openjdk
```

Download Davmail in an AppVM and qvm-copy-to-vm it over to the mail template vm
in the AppVM which has internet access:
```
wget https://kent.dl.sourceforge.net/project/davmail/davmail/4.8.4/davmail-linux-x86_64-4.8.4-2570.tgz
qvm-copy-to-vm t-mail davmail-linux-x86*
```

In the TemplateVM:
```
sudo tar -xvzf ~/QubesIncoming/<AppVM>/davmail.*.tgz -C /opt```
sudo mv /opt/davmail* /opt/davmail
```

tell your template VM where to find the GPG Vault VM.
Here the Vault VM is named my-vault 
```
export QUBES_GPG_DOMAIN=my-vault
```

test access via SplitGPG (this command should list your secret-keys in the Vault-AppVM)
```
qubes-gpg-client -K
```

Shutdown TemplateVM and create a new AppVM based on the TemplateVM
in dom0
```
qvm-shutdown --wait t-mail
qvm-create --template t-mail --label blue my-workmail
```

Open Qubes Setting for the new AppVM and increase storage capacity
Private storage max. size: 20480 MiB

Start AppVM and continue configuration there

`qvm-run --auto my-workmail gnome-terminal`

Start davmail

`/opt/davmail/davmail.sh &`

- Main Tab: Echange Protocol: Auto
- Main Tab: OWA (Exchange) URL: https://owa.domain.com/owa/
- Main Tab: [ ] Local POP port
- Advanced Tab: Default windows domain: <YOUR-DOMAIN>
- Advanced Tab: [x] Disable Update Check

tell your AppVM VM where to find the GPG Vault VM 

`echo "export QUBES_GPG_DOMAIN=my-vault" >> /home/user/.bashrc`

allow TemplateVM to acces SplitGPG Vault-AppVM
in dom0

`echo "my-workmail my-vault allow" >> /etc/qubes-rpc/policy/qubes.Gpg`

Test SplitGPG in the AppVM
Close and restart Terminal, so that the variable QUBES_GPG_DOMAIN will be set
Check if connection via SplitGPG works

`qubes-gpg-client --list-secret-keys`


## Setting up Thunderbird/Evolution with Davmail

`sudo dnf -y install evolution thunderbird`

Start Thunderbird in the AppVM

`thunderbird &`

- Create new account (use existing mail)
- choose manual config
- IMAP localhost 1143 Autodetect Autodetect
- SMTP localhost 1025 Autodetect Autodetect
- Username: <YOUR-USERNAME>
- Click on Re-Test and accept any certificate warning
- (Checking the fingerprints!)
- Click on Re-Test, then Done
- Warning about unencrypted transfer from localhost
- [x] I understand the risks


## Setting up neomutt and offlineimap with Davmail
See also: https://hobo.house/2015/09/09/take-control-of-your-email-with-mutt-offlineimap-notmuch/ assuming that you have installed and configured Davmail (see above)

### Install packages in the TemplateVM
install neomutt and offlineimap in the Template VM
dom0:

`qvm-run --auto t-mail gnome-terminal`

in the Template VM:
```
sudo dnf install dnf-plugins-core
sudo dnf copr enable flatcap/neomutt
# cyrus-sasl plain might be needed to login via SMTP
sudo dnf install neomutt dialog offlineimap git notmuch cyrus-sasl-plain
```
additional tools for a good neomutt experience
```
sudo dnf -y install w3m qutebrowser mupdf
shutdown -h now
```

restart AppVM if it was running before and your installed new packages in the Template VM
dom0:

`qvm-shutdown --wait --quiet my-workmail`
`qvm-run --auto my-workmail gnome-terminal`

Start & configure davmail (see above)

`/opt/davmail/davmail.sh &`

### Setting up neomutt
Clone mutt-wizard

`git clone https://github.com/LukeSmithxyz/mutt-wizard.git ~/.config/mutt`

Launch mutt-wizard and choose add new account

`.config/mutt/mutt-wizard.sh`

- 1 Add an email account
- start with adding something like user@qubes when asked for a GPG key
- we will manually overwrite the config-file
- fill out all entries, it's Ok if the last steps fails
- verify if the account has been created:
- 0 List all email accounts configured
- 6 Exit this wizard

Fix the configuration of offlineimap
the configuration which has been created by mutt-wizard has to be changed in order to work with Davmail
(Offlineimap will connect to davmail (localhost) and download emails)

Create directory where offlineimap will store its mail

`mkdir ~/.mail`

Create a basic configuration file
Change YOUR-USERNAME and YOUR-PASSWORD to your settings ;-)

`nano ~/.offlineimaprc`

Paste (overwrite the existing settings) the following lines into this file
```
#.offlineimaprc
[general]
accounts = workmail
starttls = no
pythonfile = ~/.offlineimap/imappwd.py

[Account workmail]
localrepository = workmail-local
remoterepository = workmail-remote

[Repository workmail-remote]
type = IMAP
remoteuser = <USERNAME>
sslcacerfile = /etc/ssl/cets/ca-certificates.crt
sslcacertfile = /etc/ssl/certs/ca-certificates.crt
remotepasseval = mailpasswd("workmail")
#mailpasswd = <PASSWORD>
remotehost = localhost
remoteport = 1143
ssl=no
folderfilter = lambda foldername: foldername in ['INBOX', 'Drafts', 'Sent', 'Trash']

[Repository workmail-local]
type = Maildir
localfolders = ~/.mail/workmail
```


```
[general]
accounts = gmail,outlook
starttls = yes
ssl = yes
pythonfile = ~/.offlineimap/imappwd.py

[Account gmail]
localrepository = gmail-local
remoterepository = gmail-remote

[Repository gmail-remote]
type = Gmail
auth_mechanisms = GSSAPI, CRAM-MD5, PLAIN
remoteuser = <USERNAME>@gmail.com
port = 993
sslcacerfile = /etc/ssl/cets/ca-certificates.crt
sslcacertfile = /etc/ssl/certs/ca-certificates.crt
remotepasseval = mailpasswd("gmail")
#mailpasswd = <PASSWORD>
folderfilter = lambda foldername: foldername not in ['[Gmail]/All Mail']

[Repository gmail-local]
type = Maildir
localfolders = ~/.mail/gmail

[Account outlook]
localrepository = outlook-local
remoterepository = outlook-remote

[Repository outlook-remote]
type = IMAP
auth_mechanisms = GSSAPI, CRAM-MD5, XOAUTH2, PLAIN
remoteuser = <USERNAME>@outlook.com
#mailpasswd = <PASSWORD>
sslcacerfile = /etc/ssl/cets/ca-certificates.crt
sslcacertfile = /etc/ssl/certs/ca-certificates.crt
remotepasseval = mailpasswd("outlook")
remotehost = imap-mail.outlook.com
port = 993

[Repository outlook-local]
type = Maildir
localfolders = ~/.mail/outlook
```

Info:
remotepasseval = mailpasswd("<NAME>") is a helper script, which decrypts your password via SplitGPG.
Place the following file in ./offlineimap
Name: .offlineimap/imappwd.py

```
import os.path
import subprocess
home = os.path.expanduser("~")
def mailpasswd(acct):
  acct = os.path.basename(acct)
  path = "%s/.offlineimap/%s.gpg" % (home,acct)
  args = ["qubes-gpg-client", "--use-agent", "--quiet", "--batch", "-d", path]
  try:
    return subprocess.check_output(args).strip()
  except subprocess.CalledProcessError:
      return ""
```

Store your encrypted password in ~/.offlineimap, where the filename should be <OfflineIMAP-Accountname>.gpg (example: workmail.gpg / gmail.gpg / outlook.gpg)

```
#Encrypt your password
# Username = ID to your Secret Key in SplitGPG
qubes-gpg-client -a --encrypt -r <USERNAME> > ~/.offlineimap/<ACCOUNTNAME>.gpg
#Check/Decrypt your password
qubes-gpg-client -d --quiet ~/.offlineimap/<ACCOUNTNAME>.gpg 
```

Create a link to the certfiles (in the template VM!)
you could also put the correct path to the certfiles into .offlineimaprc but we're using the default paths which are also configured via mutt-wizard

`cd /etc/ssl/certs/`
`sudo ln -s ca-bundle.trust.crt ca-certificates.crt`

Check if offlineimap connects to your Exchange Server and downloads email
Run offlineimap once (-o) and only for the Inbox folder (to see if it is working)

`offlineimap -f INBOX,Sent,Drafts -o`

if some mails has been synchronized, you can abort (Ctrl+C)
continue with mutt-wizard:

`.config/mutt/mutt-wizard.sh` 

- 2 Auto-detect mailboxes for an account
- 6 Exit this wizard

Make small changes to work with SplitGPG and use qubes-gpg-client instead of gpg2.

Edit: ~/.config/mutt/credentials/getmuttpass 
```
#!/bin/bash
#pass=$(gpg2 -d -q ~/.config/mutt/credentials/$1.gpg)
pass=$(qubes-gpg-client -d -q ~/.config/mutt/credentials/$1.gpg)
echo set smtp_pass=\"$pass\"
echo set imap_pass=\"$pass\"
```
Edit: ~/.config/mutt/credentials/imappwd.py
```
import os.path
import subprocess
home = os.path.expanduser("~")
def mailpasswd(acct):
  acct = os.path.basename(acct)
  path = "%s/.config/mutt/credentials/%s.gpg" % (home,acct)
#  args = ["gpg2", "--use-agent", "--quiet", "--batch", "-d", path]
  args = ["qubes-gpg-client", "--use-agent", "--quiet", "--batch", "-d", path]
  try:
    return subprocess.check_output(args).strip()
  except subprocess.CalledProcessError:
      return ""
```

Launch neomutt

`neomutt`

### Enable cronjob to run offlineimap via cron
make sure that cron is installed in the tenmplate VM
```
sudo dnf -y install cronie-anacron
```
Enable the Cron service for the AppVM (not the Template VM!) in dom0:
```
qvm-service -e my-mail crond
```
Startup AppVM and make sure that crond is running
```
service crond status
# if it is not running, try to launch it with
#service crond start
```
Create a crontab file as regular user, like this
```
crontab -e
```
put the following content into the file
```
# min  hr   day-of-month month day-of-week
# 0-59 0-23 0-31         1-12  0-7
# Check important mail folders every 5min
*/5 * * * *     /usr/bin/offlineimap -u quiet -f INBOX
# Check other mail folders every 15min
*/15 * * * *    /usr/bin/offlineimap -u quiet -f Drafts,Sent
```


### Configure notmuch search
See also: https://notmuchmail.org/

configure notmuch
`notmuch setup`

initial run

`notmuch new`



### Configure plain text vcard and vcal
```
sudo dnf -y install khal khard
```

edit: ~/.config/vdirsyncer

```
[general]
status_path = "~/.config/vdirsyncer/status/"

[pair office_kontakte]
a = "office_kontakte_lokal"https://micahflee.com/2016/06/qubes-tip-opening-links-in-your-preferred-appvm/
b = "office_kontakte_remote"
collections = ["from a", "from b"]

[storage office_kontakte_lokal]
type = "filesystem"
path = "~/.pim/contacts"
fileext = ".vcf"

[storage office_kontakte_remote]
type = "carddav"
url = "http://localhost:1080/users/<USERNAME>@<DOMAIN>/contacts"
auth = "basic"
username = "<USERNAME>"
password = "<PASSWORD>"

[pair office_kalender]
a = "office_kalender_lokal"
b = "office_kalender_remote"
collections = ["from a", "from b"]
metadata = ["color"]

[storage office_kalender_lokal]
type = "filesystem"
path = "~/.pim/calendars/"
fileext = ".ics"

[storage office_kalender_remote]
type = "caldav"
url = "http://localhost:1080/users/<USERNAME>@<DOMAIN>/calendar"
auth = "basic"
username = "<USERNAME>"
password = "<PASSWORD>"
```

To sync your contacts/calendar:
```
vdirsyncer sync
```

--- offtopic ---

Download and import an own Root CA-certificate
```
sudo cp vsrv-mail-3.pem /etc/pki/ca-trust/source
sudo update-ca-trust
```

### Setting up SplitGPG
```
# Import Key to Mail-VM
gpg --import keyfile
# set trust
gpg --edit-key demouser```

### further reading
 - https://gist.github.com/dabrahams/3030332
 - https://wjianz.wordpress.com/2014/09/03/howto-installconfigure-msmtp-and-mutt-on-ubuntu/
 - https://hobo.house/2015/09/09/take-control-of-your-email-with-mutt-offlineimap-notmuch/

### msmtp - SMTP Email
`sudo yum -y install msmtp`

Configuration file:
```
# ~/.msmtprc 
# Set default values for all following accounts defaults
tls_trust_file /etc/ssl/certs/ca-bundle.crt
logfile ~/.msmtp.log

# Gmail
account gmail
host smtp.gmail.com
from USERNAME@gmail.com
auth on
user USERNAME@gmail.com
password PASSWORD
tls on
tls_starttls on
tls_certcheck on
tls_trust_file /etc/ssl/certs/ca-bundle.crt 
```
## Open Links in an email in disposable VMs

### neomutt
FIXME!!

### Thunderbird
Open all attachments in disposable AppVM (DVM)
Use Thunderbird-Plugin: "Qubes Attachhments" and enable  "Open attachment in DispVM by default"

### Open all Weblinks in a disposable AppVM (DVM)
Create a new .desktop-file in your Emaill App-VM:
```
mkdir -p ~/.local/share/applications
nano ~/.local/share/applications/browser_dvm.desktop
# add the following content:
  [Desktop Entry]
  Encoding=UTF-8
  Name=BrowserVM
  Comment=Open Link in a Disposable VM
  Exec=qvm-open-in-dvm %u
  Terminal=false
  X-MultipleArgs=false
  Type=Application
  Categories=Network;WebBrowser;
  MimeType=x-scheme-handler/unknown;x-scheme-handler/about;text/html;text/xml;application/xhtml+xml;application/xml;application/vnd.mozilla.xul+xml;application/rss+xml;application/rdf+xml;image/gif;image/jpeg;image/png;x-scheme-handler/http;x-scheme-handler/https;
```
Use this .desktop file as your default browser in the Email AppVM
```
xdg-settings set default-web-browser browser_dvm.desktop
```

## Create a menu entry to open OWA as Webmail

Create a new file OWA-Webmail.desktop
```
[Desktop Entry]
Encoding=UTF-8
Name=globits Webmail (OWA)
Icon=my-icon
Type=Application
Categories=Office;
Exec=xdg-open https://owa.DOMAIN.de/owa/
```
