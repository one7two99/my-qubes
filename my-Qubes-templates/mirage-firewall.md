```
MirageFWBuildVM=my-mirage-buildvm
TemplateVM=fedora-30
MirageFWAppVM=sys-mirage-fw

See also https://github.com/mirage/qubes-mirage-firewall

# create a new VM
qvm-create $MirageFWBuildVM --class=AppVM --label=red --template=$TemplateVM


# Resize private disk to 10 GB
qvm-volume resize $MirageFWBuildVM:private 10GB

# Create a symbolic link to safe docker into the home directory
qvm-run --auto --pass-io --no-gui $MirageFWBuildVM \
  'sudo mkdir /home/user/docker && \
   sudo ln -s /home/user/docker /var/lib/docker'

# Install docker and git ~2min
qvm-run --pass-io --no-gui $MirageFWBuildVM \
  'sudo qvm-sync-clock && \
   sudo dnf -y install docker git'

# Launch docker
qvm-run --pass-io --no-gui $MirageFWBuildVM \
  'sudo systemctl start docker'

# Download and build mirage for qubes ~11min
qvm-run --pass-io --no-gui $MirageFWBuildVM \
  'git clone https://github.com/mirage/qubes-mirage-firewall.git && \
   cd qubes-mirage-firewall && \
   # git pull origin pull/52/head && \
   sudo ./build-with-docker.sh'

# Copy the new kernel to dom0
cd /var/lib/qubes/vm-kernels
qvm-run --pass-io $MirageFWBuildVM 'cat qubes-mirage-firewall/mirage-firewall.tar.bz2' | tar xjf -

# create a new mirage fw appvm
qvm-create \
  --property kernel=mirage-firewall \
  --property kernelopts=None \
  --property memory=32 \
  --property maxmem=32 \
  --property netvm=sys-net \
  --property provides_network=True \
  --property vcpus=1 \
  --property virt_mode=pv \
  --label=green \
  --class StandaloneVM \
  $MirageFWAppVM

# Change default NetVM to Mirage FW
qvm-start $MirageFWAppVM
qubes-prefs --set default_netvm $MirageFWAppVM
```

Further Notes/Drafts
====================
Script to rebuild mirage has to be done, as the Mirage-Build-AppVM above will loose its docker installation after shutting down.
Docker is only installed into the AppVM not the template, as such docker installarion is NOT persistent.

```
# delete old build
qvm-run --auto --pass-io --no-gui $MirageFWBuildVM \
  'rm -Rf /home/user/qubes-mirage-firewall'

# Create a symbolic link to safe docker into the home directory
qvm-run --auto --pass-io --no-gui $MirageFWBuildVM \
  'sudo mkdir /home/user/var_lib_docker && \  
   sudo ln -s /var/lib/docker /home/user/var_lib_docker'

# Install docker and git ~2min
qvm-run --pass-io --no-gui $MirageFWBuildVM \
  'sudo qvm-sync-clock && \
   sudo dnf -y install docker git'

# Launch docker
qvm-run --pass-io --no-gui $MirageFWBuildVM \
  'sudo systemctl start docker'

# Download and build mirage for qubes
qvm-run --auto --pass-io --no-gui $MirageFWBuildVM \
  'git fetch https://github.com/mirage/qubes-mirage-firewall.git && \ 
   cd qubes-mirage-firewall && \
   # git pull origin pull/52/head && \
   sudo ./build-with-docker.sh'

# Copy the new kernel to dom0
cd /var/lib/qubes/vm-kernels
qvm-run --pass-io $MirageFWBuildVM 'cat qubes-mirage-firewall/mirage-firewall.tar.bz2' | tar xjf -

# Shutdown Mirage-FW
qvm-shutdown --wait $MirageFWAppVM

# Start Mirage-FW
qvm-start $MirageFWAppVM

# Remove BuildVM
qvm-kill $MirageFWBuildVM
qvm-remove --force $MirageFWBuildVM
```
