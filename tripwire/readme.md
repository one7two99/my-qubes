Use tripwire in dom0
====================

While using Qubes is "reasonable secure" there is a possible risk that an attacker is either doing something with your hardware (example: implanting a HW keylogger in it) or changing your unencrypted /boot partition.

While there are some solutions like using heads (https://github.com/osresearch/heads) this will only work on a very limited set of hardware and most often very old hardware. I was using Coreboot on my X230 but replaced it against an X270 to get a FullHD-display, up to 32GB RAM and USB-C charging.
If you're interested in using Coreboot on the X230 you find my howto at https://github.com/one7two99/my-qubes/tree/master/docs/coreboot

In order to be at least protected against changes to the unencrypted /boot partition I was using a simple script comparing checksums but have now moved to use tripwire.

The solution
------------
The idea is to run a script after login which will trigger a tripwire run and present nice notification using notify-send and also present the tripwire log file, in case the Exit code is not 0.

![notification1](https://user-images.githubusercontent.com/831382/220892524-720cb35f-c8b9-420f-b0aa-ed88dc8271d9.png)

![notification2](https://user-images.githubusercontent.com/831382/220892534-ff6891d6-13c7-46c3-a35e-8856dcfa37a5.png)

How does it works:
- install tripwire in dom0 (one package)
- configuration of tripwire
- tripwire-autocheck script to be run on login

The following guide will describe all actions.

DISCLAIMER:
Please review my scripts so that you fully understand what the script is doing and also get a basic understanding of tripwire BEFORE you install/change anything in dom0 (as it should also be the case :-)

If you have any further questions or ideas for improvements, use the Github Issues feature above.

Installation in dom0
-------------------
The installation of tripwire in dom0 is straight forward:
```
sudo qubes-dom0-update tripwire
```

After the installation you need to create a site and local keyfile.
- The site keyfile will protect the tripwire configuration and also the policy definition file.
- the local keyfile will be used for tripwirie initialization (generating checksums)
```
sudo twadmin --generate-keys --local-keyfile /etc/tripwire/$(hostname)-local.key
sudo twadmin --generate-keys --site-keyfile /etc/tripwire/site.key
```

### Create a tripwire config file
```
sudo twadmin --create-cfgfile -S /etc/tripwire/site.key /etc/tripwire/twcfg.txt
```

### Review/Create tripwire (default) policy file
You can now review tripwire policy file (template)...
```
sudo nano /etc/tripwire/twpol.txt
```
... but it will include some references to files and directories which are not present in your dom0 as dom0 is not a full featured fedora installation.
I suggest leaving everything like it is, run a tripwire initialization and then review all errors (references to files/directories not present in dom0)

Create a tripwire policy file from the avove clear text template
```
sudo twadmin --create-polfile -S /etc/tripwire/site.key /etc/tripwire/twpol.txt
```

### Tripwire first run
Now it's time to run a tripwire init with the default policy file
```
sudo tripwire --init 
```
Hint: save output via copy & paste to tripwire-init.result.txt

### Error handling
Now it's time to take care of the errors. We will filter the output to show all files/directories which are not present in your qubes installation. 
```
cat tripwire-init.result.txt | grep Filename | gawk '{ print $3 }'
```
You need to find those references and comment them out in /etc/tripwire/twpol.txt by adding a # in front of the line.
OR you can just grab my twpol.txt file from the repository which https://github.com/one7two99/my-qubes/blob/master/tripwire/twpol.txt
I have included some binaries (lvm commands) which are present in dom0.
At the end of the file you can find some additional exclusion (Qubes specific tripwire rules) which are currently in testing state as I', trying to modify my tripwire, so that a clean reboot and a tripwire check will not trigger an alarm in tripwire.
Maybe I will drop this idea again, as such feel free to remove the section from the twpol.txt file.

Suggestion:
I suggest making a copy of the default twpol.txt file before you apply any changes
```
sudo cp /etc/tripwire/twpol.txt /etc/tripwire/twpol.txt.origin
```

### Apply changes to the policy file
Every time you make changes to the clear text policy file you need to create a new tripwire policy file and run the --init job again to get a new baseline for the tripwire check
```
sudo twadmin --create-polfile -S /etc/tripwire/site.key /etc/tripwire/twpol.txt
sudo tripwire --init
```
This time there should be no further errors, if so review and adapt your /etc/tripwire/twpol.txt again and rerun the steps to create tripwire policy file and init.

### First tripwire check
You can now compare the current state to the frozen state (tripwire --init)
```
sudo tripwire --check
```

### Add automatation on login
Now it's time to add the tripwire-autocheck.sh script ( https://github.com/one7two99/my-qubes/blob/master/tripwire/tripwire-autocheck.sh ) to be run after Qubes login by adding it to "Application Autostart" via Qubes Menu > System Tools > Session and Startup, Tab: Application Autostart:

![autostart](https://user-images.githubusercontent.com/831382/220892375-6d2aa628-3a61-4fa4-8b72-d1f5e3540536.png)
