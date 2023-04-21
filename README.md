# my-qubes

 - \docs - contains howtos
 - \dom0-scripts - Scripts for dom0
 - \my-qubes-setup - describes my current setup
 - \my-qubes-templates - howtos regarding the setup of my qubes installation 

# Download this repository
To download this repository in dom0 to make use of all teh qvm-run commands in the my-qubes-templates folder

```
# Change the my-untrusted to the AppVM from which you want to download the repository
DownloadAppVM=my-untrusted
qvm-run --pass-io --no-gui $DownloadAppVM \
   "wget -qO- https://github.com/one7two99/my-qubes/archive/refs/heads/master.zip" \
   > my-qubes.zip
unzip my-qubes.zip
rm my-qubes.zip
```
