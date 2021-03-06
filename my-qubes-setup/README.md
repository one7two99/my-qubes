# version history
```
03/2019 - initial version
```

# My setup of Qubes
this document will describe my Qubes Setup and what I did to improve the Qubes experience

This file will located in two locations:
- the Qubes Community Docs: https://github.com/Qubes-Community/Contents/tree/master/docs/user-setups/one7two99
- my personal GitHub repo: https://github.com/one7two99/my-qubes/edit/master/my-setup/README.md

--------
# About Me
Using Qubes has been a decision as I want to prove that using an alternative OS is possible.
Additinally I want to keep my data as much secure as possible.
Another benefit is that Qubes offers protection when working with one device in several customer environments.

--------
# My Hardware
I am using three devices, depending on what I need to do:

 - Lenovo X230: Windows 10 for mobile work
 - Lenovo W540: when a bigger screen or more computing power is required
 - Virtual Desktop VMware Horizon View: Corporate Windows 10 Desktop

My main device which I use ~80% of time is the X230 Core i7 which has a 2nd Slice battery, giving me more than 8h of battery runtime. 

## The favorite device -> Lenovo X230
I think this is the best laptop which has ever been build and it is my daily driver.

It is also the last X-series laptop which supports CoreBoot and therefore I will likely keep it for a few years.
- 12 inch Laptop
- Intel Core Intel Core i7-3520M @ 2.90 GHz
- 16 GB RAM
- 500 GB Intel SSD
- 1366x768 IPS-Display
- WWAN-Card for LTE connectivity
- 44++ battery
- additional Slice-Battery 19++
- Coreboot with SeaBIOS
- Qubes 4.1
- Windows 10 Enteprise (DualBoot, BitLocker enabled)

PCI devices (lspci)

00:00.0 Host bridge: Intel Corporation 3rd Gen Core processor DRAM Controller (rev 09)
00:02.0 VGA compatible controller: Intel Corporation 3rd Gen Core processor Graphics Controller (rev 09)
00:14.0 USB controller: Intel Corporation 7 Series/C210 Series Chipset Family USB xHCI Host Controller (rev 04)
00:16.0 Communication controller: Intel Corporation 7 Series/C216 Chipset Family MEI Controller #1 (rev 04)
00:19.0 Ethernet controller: Intel Corporation 82579LM Gigabit Network Connection (Lewisville) (rev 04)
00:1a.0 USB controller: Intel Corporation 7 Series/C216 Chipset Family USB Enhanced Host Controller #2 (rev 04)
00:1b.0 Audio device: Intel Corporation 7 Series/C216 Chipset Family High Definition Audio Controller (rev 04)
00:1c.0 PCI bridge: Intel Corporation 7 Series/C216 Chipset Family PCI Express Root Port 1 (rev c4)
00:1c.1 PCI bridge: Intel Corporation 7 Series/C210 Series Chipset Family PCI Express Root Port 2 (rev c4)
00:1d.0 USB controller: Intel Corporation 7 Series/C216 Chipset Family USB Enhanced Host Controller #1 (rev 04)
00:1f.0 ISA bridge: Intel Corporation QM77 Express Chipset LPC Controller (rev 04)
00:1f.2 SATA controller: Intel Corporation 7 Series Chipset Family 6-port SATA Controller [AHCI mode] (rev 04)
00:1f.3 SMBus: Intel Corporation 7 Series/C216 Chipset Family SMBus Controller (rev 04)
02:00.0 System peripheral: Ricoh Co Ltd PCIe SDXC/MMC Host Controller (rev 07)
03:00.0 Network controller: Intel Corporation Centrino Advanced-N 6205 [Taylor Peak] (rev 34)

Wifi driver in sys-net: iwl6000g2a-firmware


## The work horse -> Lenovo W540
not very often in use, as the X230 is so versatile and the W540 doesn't run with Coreboot and has a much shorter battery runtime.

00:06.0 Network controller: Intel Corporation Wireless 7260 (rev 83)
- Subsystem: Intel Corporation Dual Band Wireless-AC 7260
- Kernel driver in use: iwlwifi -> iwl7260-firmware
- Kernel modules: iwlwifi

## Virtual Desktop (VMware Horizon View)
a virtual desktop which I can use from everywhere which is based on VMware Horizon View (PCoIP-protocol).
This is my main corporate desktop to work with windows, an ERP etc.

--------
# My Setup
I have to run a dual boot system as I need to run Windows for specific tasks.
But as we are able to use virtual desktops, if I need windows, I connect to my corporate virtual desktop as the X230 has WWAN connectivity.


## My currently installed AppVMs and Templates

### TemplateVMs (default)
```
NAME               STATE    CLASS         LABEL   TEMPLATE           NETVM
debian-9           Halted   TemplateVM    black   -                  -
fedora-30          Halted   TemplateVM    black   -                  -
fedora-30-minimal  Halted   TemplateVM    black   -                  -
whonix-gw-14       Halted   TemplateVM    black   -                  -
whonix-ws-14       Halted   TemplateVM    black   -                  -
```
### TemplateVMs (custom build)
```
NAME               STATE    CLASS         LABEL   TEMPLATE           NETVM
t-fedora-30-apps   Halted   TemplateVM    black   -                  -
t-fedora-30-mail   Halted   TemplateVM    black   -                  -
t-fedora-30-media  Halted   TemplateVM    black   -                  -
t-fedora-30-sys    Halted   TemplateVM    black   -                  -
t-fedora-30-work   Halted   TemplateVM    black   -                  -
```

### StandaloneVMs
```
NAME               STATE    CLASS         LABEL   TEMPLATE           NETVM
my-win7            Halted   StandaloneVM  gray    -                  sys-mirage-fw
sys-mirage-fw      Running  StandaloneVM  green   -                  sys-vpn
```

### AppVMs
```
NAME               STATE    CLASS         LABEL   TEMPLATE           NETVM
anon-whonix        Halted   AppVM         red     whonix-ws-14       sys-whonix
my-aboutprivacy    Halted   AppVM         blue    t-fedora-30-apps   sys-mirage-fw
my-bizmail         Halted   AppVM         blue    t-fedora-30-mail   sys-mirage-fw
my-globits         Halted   AppVM         blue    t-fedora-30-work   sys-mirage-fw
my-media           Halted   AppVM         orange  t-fedora-30-media  sys-firewall
my-privmail        Halted   AppVM         blue    t-fedora-30-mail   sys-mirage-fw
my-storage         Running  AppVM         green   fedora-30          sys-mirage-fw
my-untrusted       Halted   AppVM         orange  t-fedora-30-apps   sys-mirage-fw
my-vault           Halted   AppVM         black   t-fedora-30-apps   -

### SysVMs
```
NAME               STATE    CLASS         LABEL   TEMPLATE           NETVM
default-mgmt-dvm   Halted   AppVM         black   fedora-30          -
sys-firewall       Halted   AppVM         red     t-fedora-30-sys    sys-net
sys-net            Running  AppVM         red     t-fedora-30-sys    -
sys-usb            Running  AppVM         red     t-fedora-30-sys    -
sys-vpn            Running  AppVM         blue    t-fedora-30-sys    sys-net
sys-whonix         Halted   AppVM         black   whonix-gw-14       sys-mirage-fw
```

### Disposable AppVMs
```
NAME               STATE    CLASS         LABEL   TEMPLATE           NETVM
my-dvm             Halted   AppVM         red     t-fedora-30-apps   sys-mirage-fw
whonix-ws-14-dvm   Halted   AppVM         red     whonix-ws-14       sys-whonix
```


## System defaults

Dom0 UpdateVM: sys-firewall
ClockVM: sys-net
Default NetVM: sys-mirage-fw
Default template: t-fedora-30-apps
Default DispVM: my-dvm




--------
# My Templates
In order to understand how Qubes OS is working and to have a minimal setup I have choosen to use custom build templates, which are all based on fedora-28-minimal templates.
This makes sure that I have only those packages installed, which I need.
Additionally the setup of templates is mainly done by scripts which I can run from dom0.
Therefore it is very easy to rebuild the whole system from scratch - something which I think is important in case that you have the feeling something might be not running correctly.

I have the following two baseline-templates:
 - debian-9 (replaced 02/2019 with a fedora-29-template)
 - fedora-29-minimal
"baseline" means that those templates are never updated or changed as they are used as seed for my other templates.
I qvm-clone those templates and then work on the copy.
This allows me to always jump back to cleanest template and rebuild from scratch.

I developed a naming scheme as I have several AppVMs and TemplateVMs:
- all custom build TemplateVMs start with t-DISTRIBUTION-VERSION-NAME. For example t-fedora-29-apps is a template, whoch is based on fedora 29 minimal and has additional packages for my default (fat) Apps-VMs
- all system VMs, start with sys- like sys-net, sys-firewall, sys-usb, sys-vpn
- all other AppVMs, start with my-PURPOSE, for example my-multimedia

## Custom build templates:
### t-debian-9-multimedia
Template for a Multimedia AppVM, see my [Multimedia Howto](https://www.qubes-os.org/doc/multimedia/)
 - Chrome
 - VLC
 - Spotify

### t-fedora-29-apps
this is my default fat AppVM template, installed packages:
 - firefox
 - libreoffice
 - firefox
 - ...

### t-fedora-29-mail
this is my template for email tasks, it has installed:
 - Thunderbird
 - Neomutt
 - Davmail (to connect to my corporate microsoft exchange server)
 - Offlineimap
 - ...
 I am separating email in two AppVMs for private use and corporate use.
 attachments from those VMs will be opened in disposable AppVMs.
 
### t-fedora-29-storage
a special template which can be used to store data into one AppVM and share it securly with others via special scripts (which I am proud of :-).
 - sshfs for sharing data betwenn VMs
 - CryFS for data encryption
 - EncFS for data encryption
 - onedrived to be able to sync (only encrypted data) to the cloud
The whole setup includes 3 AppVMs:
- Storage AppVM - stores the data and encrypts it using EncFS or CryFS
- Access AppVM - can access the Storage AppVM and is able to decrypt
- Sync AppVM - which can sync encrypted data to onedrive (only used for getting data out of onedrive,  but could be used in two directions)
management of those setup is done via one (!) script which can also build the templates and AppVM.

### t-fedora-29-sys
template for my sys-vms and also for VPN connectivity
a VPN or ProxyVM which can be used to run all traffic through ExpressVPN.
This adds a great layer of privacy to qubes as my ISP can't analyse my traffic.
I have written a howto [How to use ExpressVPN as ProxyVM with Qubes 4](https://github.com/one7two99/my-qubes/blob/master/docs/howto-use-expressvpn-with-qubes.md)

 - sys-usb
 - sys-firewall
 - sys-net
 - sys-vpn
 
### t-fedora-29-work
My work tenmplate which has Vmware Horizon View, Cisco AnyConnect, Firefox and LibreOffice installed.

### other templates
the Whonix templates which come preinstalled with Qubes 4
