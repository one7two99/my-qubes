
```
# Clone a Debian template
sudo apt-get update && sudo apt-get upgrade
sudo shutdown -h now
cd QubesIncoming/my-untrusted/
sudo apt-get install gdebi
wget http://crossover.codeweavers.com/redirect/crossover.deb
sudo gdebi crossover_17.1.0-1.deb
cd /opt/cxoffice/
./cxinstaller
sudo shutdown -h now
sudo apt-get -y install mlocate mc
# Install Excel via Crossover
cd /usr/share/applications/
sudo cp thunderbird.desktop cxoffice-excel.desktop
sudo nano cxoffice-excel.desktop
sudo shutdown -h now
find -type f -exec md5sum '{}' \;
find -type f \( -not -name "md5sum.txt" \) -exec md5sum '{}' \; > md5sum.txt
md5sum --check /tmp/md5sum.txt | grep --invert-match ": OK"
```
