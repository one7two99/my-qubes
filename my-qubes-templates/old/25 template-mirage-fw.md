Mirage unikernel firewall
=========================
```
#!/bin/bash
# Script to download and install qubes-mirage-firewall
# Adapt variables to latest version and your needs
# Check GitHub Project Page:
#   https://github.com/mirage/qubes-mirage-firewall

# Some variables
Release=v0.8.4
DownloadVM=anon-whonix
MirageFW=sys-mirage-fw

GithubUrl=https://github.com/mirage/qubes-mirage-firewall
Filename=mirage-firewall.tar.bz2
DownloadBinary=$GithubUrl/releases/download/$Release/$Filename
MirageInstallDir=/var/lib/qubes/vm-kernels/mirage-firewall

# Download and unpack in DownloadVM
qvm-run -a --pass-io --no-gui $DownloadVM "wget $DownloadBinary"
qvm-run -a --pass-io --no-gui $DownloadVM "tar -xvjf $Filename"

# Install mirage kernel
mkdir -p $MirageInstallDir
cd $MirageInstallDir
qvm-run --pass-io --no-gui $DownloadVM "cat mirage-firewall/vmlinuz" > vmlinuz
gzip -n9 < /dev/null > initramfs

# Create sys-mirage-fw
qvm-create \
  --property kernel=mirage-firewall \
  --property kernelopts='' \
  --property memory=32 \
  --property maxmem=32 \
  --property netvm=sys-net \
  --property provides_network=True \
  --property vcpus=1 \
  --property virt_mode=pvh \
  --label=gray \
  --class StandaloneVM \
  $MirageFW
qvm-features $MirageFW qubes-firewall 1
qvm-features $MirageFW no-default-kernelopts 1

# Cleanup in DownloadVM
qvm-run -a --pass-io --no-gui $DownloadVM "rm $Filename; rm -R ~/mirage-firewall"
```
