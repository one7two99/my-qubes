t-fedora-30-cisco
=================

A template to work with Cisco Devices / IT Management

```
systemplate=t-debian-30-cisco

qvm-run --auto --user root --pass-io --no-gui $systemplate \
'apt-get install -y icedtea-netx default-jre'
```

To launch ASDM for management:

```
/usr/bin/javaws https://192.168.1.1/admin/public/asdm.jnlp
```
