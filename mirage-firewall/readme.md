How to install the superlight mirage-firewall for Qubes OS
==========================================================

Warning:
This short howto will not build the mirage-firewall from the sources but download the binary version from the mirage-firewall-project.
As such use this binary carefully.
I hope that the Qubes Team or the mirage-firewall project will provide fingerprints to verify the binary.

mirage-firewall is a firewall which can be used in Qubes OS and has very (!) low memory and CPU requirements.
To learn more about mirage-firewall, visit the GitHub page at https://github.com/mirage/qubes-mirage-firewall.

To download and install the qubes-mirage firewall, run the following action from dom0.
It will download the binary file and create a mirage-firewall qube, which you can use as NetVM for AppVMs or other NetVMs.

To download this text/the script to your dom0 you can run the following command from dom0:
Hints:

- wget ... is used to download the file in anon-whonix
- ```--quiet``` ... will surpress any status messages when using the wget command
- ```--output-document -``` ... will output the document to StdOut and this will be send to dom0 via --pass-io.

```
qvm-run --auto --pass-io anon-whonix \
"wget --quiet --output-document - https://raw.githubusercontent.com/one7two99/my-qubes/master/mirage-firewall/readme.md" \
> qubes-mirage-firewall_readme.md
```

Use the issue tab to ask or leave comments.

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

