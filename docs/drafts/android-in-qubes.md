```
Android-x86 7.1-r2 with GAPPS installation guide
https://mail.google.com/mail/u/0/#inbox/FMfcgxvzLrKflgVVLszNrZtzHvkLDNGh

I've successfully build android-x86 7.1-r2 with gapps in whonix-14-ws AppVM.

1. Install packages in whonix-14-ws template:

sudo apt-get install openjdk-8-jdk git-core gnupg flex bison gperf build-essential zip curl zlib1g-dev gcc-multilib g++-multilib libc6-dev-i386 lib32ncurses5-dev x11proto-core-dev libx11-dev lib32z-dev libgl1-mesa-dev libxml2-utils xsltproc unzip gettext python-pip libyaml-dev dosfstools syslinux syslinux-utils xorriso mtools makebootfat lunzip

2. Create builder AppVM based on whonix-14-ws in which you'll build android-x86:
You'll need 120GB for android-x86 sources and temp build files and 30GB for swap.
Extend private storage size to 160GB via GUI or in dom0:
qvm-volume extend android-builder:private 160g

Add 30GB swap in builder VM:

sudo dd if=/dev/zero of=/rw/swapfile bs=1024 count=31457280
sudo chown root:root /rw/swapfile
sudo chmod 0600 /rw/swapfile
sudo mkswap /rw/swapfile
sudo swapon /rw/swapfile

In builder VM run:

sudo ln -s /sbin/mkdosfs /usr/local/bin/mkdosfs
sudo pip install prettytable Mako pyaml dateutils --upgrade
export _JAVA_OPTIONS="-Xmx8G"
echo 'export _JAVA_OPTIONS="-Xmx8G"' >> ~/.profile
echo "sudo swapon /rw/swapfile" >> /rw/config/rc.local

Download android-x86 sources:

mkdir android-x86
cd android-x86
curl https://storage.googleapis.com/git-repo-downloads/repo > repo
chmod a+x repo
sudo install repo /usr/local/bin
rm repo
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
repo init -u git://git.osdn.net/gitroot/android-x86/manifest -b android-x86-7.1-r2

To add GAPPS to your build you need to add the build system, and the wanted sources to your manifest.
Edit .repo/manifests/default.xml and add the following towards the end:

<remote name="opengapps" fetch="https://github.com/opengapps/"  />
<project path="vendor/opengapps/build" name="aosp_build" revision="master" remote="opengapps" />
<project path="vendor/opengapps/sources/all" name="all" clone-depth="1" revision="master" remote="opengapps" />
<project path="vendor/opengapps/sources/x86" name="x86" clone-depth="1" revision="master" remote="opengapps" />
<project path="vendor/opengapps/sources/x86_64" name="x86_64" clone-depth="1" revision="master" remote="opengapps" />

Download sources:
repo sync --no-tags --no-clone-bundle --force-sync -j$( nproc --all )

If you choose to add GAPPS, then edit file device/generic/common/device.mk and add at the beginning:

#OpenGAPPS

GAPPS_VARIANT := pico

GAPPS_PRODUCT_PACKAGES += Chrome \
    KeyboardGoogle \
    LatinImeGoogle \
    GoogleTTS \
    YouTube \
    PixelIcons \
    PixelLauncher \
    Wallpapers \
    PixelLauncherIcons \
    WebViewGoogle \
    GoogleServicesFramework \
    GoogleLoginService \

GAPPS_FORCE_BROWSER_OVERRIDES := true
GAPPS_FORCE_PACKAGE_OVERRIDES := true

GAPPS_EXCLUDED_PACKAGES := FaceLock \
    AndroidPlatformServices \
    PrebuiltGmsCoreInstantApps \

And at the end add:

#OpenGAPPS
$(call inherit-product, vendor/opengapps/build/opengapps-packages.mk)

Edit android-x86 sources for XEN compatibility:
sed -i -e 's|/sys/block/\[shv\]d\[a-z\]|/sys/block/\[shv\]d\[a-z\] /sys/block/xvd\[a-z\]|g' bootable/newinstaller/install/scripts/1-install
sed -i -e 's|/sys/block/\[shv\]d\$h/\$1|/sys/block/\[shv\]d\$h/\$1 /sys/block/xvd\$h/\$1|g' bootable/newinstaller/install/scripts/1-install
sed -i -e 's|hmnsv|hmnsvx|g' bootable/newinstaller/initrd/init

Edit android-x86 sources for Debian build environment:
sed -i -e 's|genisoimage|xorriso -as mkisofs|g' bootable/newinstaller/Android.mk

Configure build target:
. build/envsetup.sh
lunch android_x86_64-eng

Configure kernel:
make -C kernel O=$OUT/obj/kernel ARCH=x86 menuconfig
You need to edit these parameters:
XEN=yes
XEN_BLKDEV_BACKEND=yes
XEN_BLKDEV_FRONTEND=yes
XEN_NETDEV_BACKEND=no
XEN_NETDEV_FRONTEND=no
SECURITY_SELINUX_BOOTPARAM=yes
SECURITY_SELINUX_BOOTPARAM_VALUE=1
SECURITY_SELINUX_DISABLE=yes
DEFAULT_SECURITY_SELINUX=yes

The kernel config will be in out/target/product/x86_64/obj/kernel/.config

Also, you can edit the config to set the device type from tablet to phone.
Edit device/generic/common/device.mk and change PRODUCT_CHARACTERISTICS from tablet to default:
PRODUCT_CHARACTERISTICS := default

Start the build:
m -j$( nproc --all ) iso_img

After you got the iso, create the android network VM. If you choose the android VM's netvm as sys-whonix directly, the network won't work. You need to have intermediate netvm between android VM and sys-whonix. Create new AppVM sys-android based on fedora template with netvm sys-whonix and set "provides network".

Create android VM in dom0:
qvm-create --class StandaloneVM --label green --property virt_mode=hvm android
qvm-prefs android kernel ''
qvm-prefs android 'sys-android'
qvm-prefs android memory '2048'
qvm-prefs android maxmem '2048'
qvm-volume extend android:root 20g

Start the android VM with iso:
qvm-start android --cdrom=android-builder:/home/user/android-x86/out/target/product/x86_64/android_x86_64.iso

Install android-x86 on xvda and reboot.

Start android VM without iso:
qvm-start android
When it'll start, kill the VM and wait for it to halt.
Configure android VM to use the mouse in dom0:
sudo mkdir -p /etc/qubes/templates/libvirt/xen/by-name/
sudo cp /etc/libvirt/libxl/android.xml /etc/qubes/templates/libvirt/xen/by-name/android.xml
sudo sed -i -e 's/tablet/mouse/g' /etc/qubes/templates/libvirt/xen/by-name/android.xml

Start android VM without iso and it should work fine:
qvm-start android

-----
	
You can try this image, but I advise to build your own image for security reasons:
https://drive.google.com/open?id=1KGDRe9iJgjb3nSBjFlK74Sa_nn08qYiq

-----

>> Thank Alex! Does not boot for me, vm halts after "Probing EDD" :(

At which point did you get this error?
Did you create android VM according to guide?
>Create android VM in dom0:
>qvm-create --class StandaloneVM --label green --property virt_mode=hvm android
>qvm-prefs android kernel ''
>qvm-prefs android 'sys-android'
>qvm-prefs android memory '2048'
>qvm-prefs android maxmem '2048'
>qvm-volume extend android:root 20g
What's your Qubes version? It works on my Qubes 4.0.
I think it should be related to kernel option:
>qvm-prefs android kernel ''
https://github.com/QubesOS/qubes-issues/issues/3419

On Saturday, December 1, 2018 at 7:05:08 PM UTC, alex.jo...@gmail.com wrote:
> At which point did you get this error?
> Did you create android VM according to guide?
> >Create android VM in dom0:
> >qvm-create --class StandaloneVM --label green --property virt_mode=hvm android
> >qvm-prefs android kernel ''
> >qvm-prefs android 'sys-android'
> >qvm-prefs android memory '2048'
> >qvm-prefs android maxmem '2048'
> >qvm-volume extend android:root 20g
> What's your Qubes version? It works on my Qubes 4.0.
> I think it should be related to kernel option:
> >qvm-prefs android kernel ''
> https://github.com/QubesOS/qubes-issues/issues/3419

You are right, the issue was due to missing `qvm-prefs android kernel ''`.

Everything works fine now, if we can call fine inability to change screen resolution, absence of sound and file exchange and semi-defunct mouse.

------

On Tuesday, February 19, 2019 at 10:38:39 AM UTC, nosugar...@gmail.com wrote:
> Hi Alex,
> 
> Let me just start by saying a massive thank you. This guide has been great. I have used it for the 8.1 - Oreo - which was just changing:
>  'repo init -u git://git.osdn.net/gitroot/android-x86/manifest -b android-x86-7.1-r2' to 'repo init -u git://git.osdn.net/gitroot/android-x86/manifest -b oreo-x86.'
> 
> With 8.1, mouse support comes out the box and completing the last part of the guide actually makes the mouse worse in Oreo. So, disregard that part anyone following this guide for 8.1. You can change resolution by affixing 'vga=ask' and choosing your desired resolution (https://groups.google.com/forum/#!topic/qubes-users/KZm8aGJuiO0).
> 
> I have come across one issue, and I am wondering if you could help me. Android has installed great, and loads up fine. However, I simply cannot open the Settings app, as it crashes every single time. Others who have encountered this issue modified it using adb (https://stackoverflow.com/questions/3480201/how-do-you-install-an-apk-file-in-the-android-emulator?rq=1), but I don't know how to do this with a Qubes HVM. Any help with this?
> 
> Thanks in advance :)

You can use adb via network:
Create tmpvm with adb.
Select Networking vm for tmpvm with adb to sys-android.
Select Networking vm for Android VM to sys-android.

In sys-android run:
sudo nft add rule ip qubes-firewall forward meta iifname eth0 accept
sudo iptables -I FORWARD 2 -i vif+ -s 10.137.0.0/24 -d 10.137.0.0/24 -p tcp -m conntrack --ctstate NEW -j ACCEPT

In android terminal run:
su
setprop service.adb.tcp.port 5555
stop adbd
start adbd

In tmpvm witd adb run:
adb connect 10.137.0.xx:5555
Where 10.137.0.xx - android IP
And then run your commands.
```
