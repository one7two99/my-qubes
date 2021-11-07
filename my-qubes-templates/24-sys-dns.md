How to NextDNS.io under Qubes OS 4.1 (sys-dns NetVM Qube)
=========================================================
sys-dns is a NetVM which can be setup between sys-net and an AppVM and will work as DNS server for the connected AppVms.
The DNS SysVM will use stubby as local DNS server and is using DNS-over-TLS using NextDNS.io nameservers (https://nextdns.io).

It will work in both scenarios:
```
template=debian-10-minimal
systemplate=t-debian-10-sys

#remove old template
qvm-kill $systemplate
qvm-remove -f $systemplate

#clone template
qvm-clone $template $systemplate

# update template
qvm-run --auto --user root --pass-io --no-gui $systemplate \
  'apt-get update && apt-get -y upgrade && apt autoremove'

# debian
qvm-run --auto --user root --pass-io --no-gui $systemplate \
  'apt-get install \
        pciutils usbutils less psmisc nano unzip wget git libnotify-bin \
        qubes-core-agent-networking qubes-core-agent-dom0-updates \
        qubes-usb-proxy qubes-input-proxy-sender \
        qubes-menus qubes-gpg-split qubes-mgmt-salt-vm-connector zenity \
        network-manager network-manager-openconnect network-manager-openconnect-gnome \
        network-manager-openvpn network-manager-openvpn-gnome \
        qubes-core-agent-network-manager \
        wireless-tools usb-modeswitch modem-manager-gui firmware-iwlwifi'

# More tools
qvm-run --auto --user root --pass-io --no-gui $systemplate \
  'apt-get install dnsutils iputils'

qvm-run --auto --user root --pass-io --no-gui $systemplate \
  'apt-get install tcpdump telnet nmap ncat git'


- sys-net <- sys-dns <- sys-firewall <- AppVM(s)
- sys-net <- sys-firewall <- sys-dns <- AppVM(s)

The NetVM is based on a debian-11-minimal template (also it will also work with a debian-10-minimal template)

Prepare Template
----------------
```
# Name of base template a new template
template=debian-11-minimal
systemplate=t-debian-11-sys

#clone template
qvm-clone $template $systemplate

# update template
qvm-run --auto --user root --pass-io --no-gui $systemplate \
  'apt-get update && apt-get -y upgrade && apt autoremove'

qvm-run --auto --user root --pass-io --no-gui $systemplate \
  'apt-get install \
        pciutils usbutils less psmisc nano unzip wget git libnotify-bin \
        qubes-core-agent-networking qubes-core-agent-dom0-updates \
        qubes-usb-proxy qubes-input-proxy-sender \
        qubes-menus qubes-gpg-split qubes-mgmt-salt-vm-connector zenity \
        network-manager network-manager-openconnect network-manager-openconnect-gnome \
        network-manager-openvpn network-manager-openvpn-gnome \
        qubes-core-agent-network-manager \
        wireless-tools usb-modeswitch modem-manager-gui firmware-iwlwifi'

# A few tools which might be helpfull for troubleshooting network related problems
qvm-run --auto --user root --pass-io --no-gui $systemplate \
  'apt-get install dnsutils iputils tcpdump telnet nmap ncat git'
```

Setup the DNS SysVM
-------------------
```
TemplateVM=t-debian-11-sys
DNSAppVM=sys-dns
NetVM=sys-net
qvm-create --template $TemplateVM --label red $DNSAppVM
qvm-prefs $DNSAppVM provides_network true
qvm-prefs $DNSAppVM netvm $NetVM
qvm-service $DNSAppVM disable-dns-server on

# make config directory persistent
qvm-run --auto --pass-io --user root $DNSAppVM 'mkdir -p /rw/config/qubes-bind-dirs.d'
qvm-run --auto  --user root $DNSAppVM 'xterm -e "nano /rw/config/qubes-bind-dirs.d/50_user.conf"'
# paste this:
binds+=( '/etc/stubby/stubby.yml' )

# restart AppVM, so that /etc/stubby/stubby.yml can be edited (persistent)
qvm-shutdown --wait $DNSAppVM

qvm-run --user root  $DNSAppVM "xterm -e 'nano /etc/stubby/stubby.yml'"
# populate stubby.yml with settings from NextDNS (take care of blank spaces!)
round_robin_upstreams: 1 
upstream_recursive_servers: 
- address_data: 45.90.28.0                          
  tls_auth_name: "SEENEXTDNSACCOUNT.dns1.nextdns.io"                          
- address_data: SEENEXTDNSACCOUNT
  tls_auth_name: "SEENEXTDNSACCOUNT.dns1.nextdns.io" 
- address_data: 45.90.30.0                          
  tls_auth_name: "SEENEXTDNSACCOUNT.dns2.nextdns.io" 
- address_data:SEENEXTDNSACCOUNT 
  tls_auth_name: "SEENEXTDNSACCOUNT.dns2.nextdns.io" 

# modify init script, so that DNSAppVM will launch stubby
qvm-run --user root  $DNSAppVM "xterm -e 'nano /rw/config/rc.local'"

# ------ Start copy & paste
### stop resolvconf and systemd-resolved (we will use stubby)
systemctl stop resolvconf
systemctl stop systemd-resolved

# start stubby DNS
systemctl start stubby
# setup stubby (localhost) as DNS
echo "nameserver 127.0.0.1" > /etc/resolv.conf

### How do I setup a custom DNS in AppVM
### https://forum.qubes-os.org/t/how-do-i-setup-a-custom-dns-in-appvm/5207/4
### from turkja Jul 20
#!/bin/sh
# This will Flush PR-QBS chain
iptables -t nat -F PR-QBS
# Redirects all the DNS traffic to localhost:53
iptables -t nat -I PR-QBS -i vif+ -p udp --dport 53 -j DNAT --to-destination 127.0.0.1
# Accepts the traffic coming to localhost
# from XEN's virtual interfaces on port 53
iptables -I INPUT -i vif+ -p udp --dport 53 -d 127.0.0.1 -j ACCEPT
# Enable the traffic coming from the virtual interfaces
# forwarded to the loopback interface
# enabling the route_localnet flag on them
echo 1 > /proc/sys/net/ipv4/conf/default/route_localnet
# ------ End copy & paste

# shutdown the new DNS VM
qvm-shutdown --wait $DNSAppVM
```

If you find out that something is not working, please leave a comment here.
