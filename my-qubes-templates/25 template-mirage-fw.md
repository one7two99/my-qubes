Mirage unikernel firewall
=========================
These commands will setup a build-VM to build the mirage kernel, build the kernel, copy it to domß and will also create the mirage unikernel firewall itself.

See also: https://github.com/mirage/qubes-mirage-firewall

Status: not (yet) working
Date: 17.10.21 with Qubes 4.1rc1
Problem: the mirage firewall will start, but will halt after a few seconds. Still looking for the root cause.

```
### Naming of variables
TemplateVM=fedora-30
MirageFWBuildVM=fedora-30-miragebuildvm
MirageFWAppVM=sys-mirage-fw
MyNetVM=sys-firewall

### create a temporary BuildVM to build the mirage kernel
qvm-create $MirageFWBuildVM --class=StandaloneVM --label=red --template=$TemplateVM
qvm-volume resize $MirageFWBuildVM:private 10GB
qvm-prefs --set $MirageFWBuildVM netvm $MyNetVM    

### prequisitis to add the docker repository
qvm-run --auto --pass-io --no-gui $MirageFWBuildVM \
    'mkdir /home/user/docker'

qvm-run --auto --pass-io --no-gui --user=root $MirageFWBuildVM \
     'ln -s /home/user/docker /var/lib/docker && \
      qvm-sync-clock && dnf -y upgrade && dnf -y install docker git && \
      systemctl start docker'

qvm-run --auto --pass-io --no-gui $MirageFWBuildVM \
    'git clone https://github.com/mirage/qubes-mirage-firewall.git && \
     cd qubes-mirage-firewall && \
     git pull origin pull/52/head'

qvm-run --auto --pass-io --no-gui --user=root $MirageFWBuildVM \
     'cd /home/user/qubes-mirage-firewall && \
     ./build-with-docker.sh'

### copy mirage unikernel to dom0
cd /var/lib/qubes/vm-kernels
qvm-run --pass-io $MirageFWBuildVM 'cat qubes-mirage-firewall/mirage-firewall.tar.bz2' | tar xjf -

### create a dummy file required for qubes
gzip -n9 < /dev/null > /var/lib/qubes/vm-kernels/mirage-firewall/initramfs

### create new sys-mirage-fw
qvm-create $MirageFWAppVM \
   --property kernel=mirage-firewall \
   --property kernelopts='' \
   --property memory=64 \
   --property maxmem=64 \
   --property netvm=sys-vpn \
   --property provides_network=True \
   --property vcpus=1 \
   --property virt_mode=pvh \
   --label=red \
   --class StandaloneVM
qvm-features $MirageFWAppVM qubes-firewall 1
qvm-features $MirageFWAppVM no-default-kernelopts 1

### set mirage as default NetVM
qubes-prefs --set default_netvm $MirageFWAppVM

### Remove the buildvm
qvm-shutdown -f $MirageFWBuildVM
qvm-remove -f $MirageFWBuildVM

```
