#!/bin/bash
# kicksecure.sh
# Distro morphing debian-11-minimal to Kicksecure
# URL: https://www.whonix.org/wiki/Kicksecure/Debian

TemplateVM=t-debian-11-kicksecure
AppVM=my-kicksecure

# install debian-11-minimal
qvm-template --enablerepo qubes-templates-itl-testing install debian-11-minimal
# clone into a new template
qvm-clone debian-11-minimal $TemplateVM

qvm-run --pass-io --no-gui --user=root $TemplateVM 'apt-get update && apt-get dist-upgrade'
qvm-run --pass-io --no-gui --user=root $TemplateVM 'apt-get -y install zenity pulseaudio-qubes qubes-menus qubes-core-agent-networking qubes-mgmt-salt-vm-connector'
qvm-run --pass-io --no-gui --user=root $TemplateVM 'apt-get -y install --no-install-recommends sudo adduser'
qvm-run --pass-io --no-gui --user=root $TemplateVM 'addgroup -system console && adduser user console && adduser user sudo'

qvm-shutdown $TemplateVM

qvm-run --pass-io --no-gui --user=root $TemplateVM 'apt-get -y install --no-install-recommends curl'
qvm-run --pass-io --no-gui --user=root $TemplateVM 'curl --proxy http://127.0.0.1:8082/ --tlsv1.3 --proto =https --max-time 180 --output derivative.asc https://www.whonix.org/derivative.asc'
qvm-run --pass-io --no-gui --user=root $TemplateVM 'cp derivative.asc /usr/share/keyrings/derivative.asc'
qvm-run --pass-io --no-gui --user=root $TemplateVM 'echo "deb [signed-by=/usr/share/keyrings/derivative.asc] https://deb.whonix.org bullseye main contrib non-free" | sudo tee /etc/apt/sources.list.d/derivative.list'
qvm-run --pass-io --no-gui --user=root $TemplateVM 'apt-get update'
qvm-run --pass-io --no-gui --user=root $TemplateVM 'apt-get dist-upgrade'
qvm-run --pass-io --no-gui --user=root $TemplateVM 'apt-get -y install --no-install-recommends kicksecure-qubes-gui'
qvm-run --pass-io --no-gui --user=root $TemplateVM 'mv /etc/apt/sources.list ~/'
qvm-run --pass-io --no-gui --user=root $TemplateVM 'touch /etc/apt/sources.list'

qvm-shutdown $TemplateVM

# creare new AppVM based on the Kickstart TemplateVM
qvm-create -C AppVM -l red --template $TemplateVM $AppVM
