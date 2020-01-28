t-fedora-30-cisco
=================

A template to work with Cisco Devices / IT Management

```
Template=debian-9
TemplateName=t-debian-9-cisco
qvm-kill $TemplateName
qvm-remove --force $TemplateName
qvm-start --skip-if-running sys-firewall
qvm-clone $Template $TemplateName
qvm-run --auto --user root --pass-io --no-gui $TemplateName \
'apt-get -y update && \
 apt-get install -y icedtea-netx default-jre'
```

To launch ASDM for management:

```
/usr/bin/javaws https://192.168.1.1/admin/public/asdm.jnlp
```
