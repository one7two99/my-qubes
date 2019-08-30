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
#qvm-run --auto --user root --pass-io --no-gui $TemplateName \
#  'dnf install -y e2fsprogs'

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
# https://sourceforge.net/projects/davmail/files/davmail
DownloadAppVM=my-media
# Transfer davmail to template
qvm-run --auto --pass-io $DownloadAppVM 'cat Downloads/davmail-*.zip' | \
  qvm-run --pass-io $TemplateName 'cat > /home/user/davmail.zip'
# Install davmail package
qvm-run --auto --pass-io --no-gui --user root $TemplateName \
  "mkdir -p /opt/davmail && \
   unzip /home/user/davmail.zip -d /opt/davmail"
# ------------------------------

qvm-shutdown $TemplateName 

qvm-create --template=$TemplateName --label=blue my-bizmail
qvm-create --template=$TemplateName --label=blue my-privmail


### Thunderbird
Download Hide Local Folders



