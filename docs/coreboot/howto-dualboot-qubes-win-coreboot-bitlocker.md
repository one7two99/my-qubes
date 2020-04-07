Dual Boot / Qubes / CoreBoot
============================
How to install Qubes OS + Windows 10 + Coreboot + BitLocker-encryption with Boot-PIN

```
[x] Windows installieren ohne BitLocker (!)
[x] EasyBCD https://neosmart.net/EasyBCD/ installieren
[x] Gruppenrichtlinie bearbeiten
	Administrative Vorlagen > Windows Komponenten > Bitlocker-Laufwerksverschlüsselung > Betriebssystemlaufwerke
	[x] Zusätzliche Authentifizierung beim Start anfordern -> Systemstart-PIN bei Systemstart zulassen
	[x] Minimale PIN-Länge für Systemstart konfigurieren -> 6 Zeichen
[x] Qubes installieren
[x] Konfiguration DualBoot
	[x] Qubes: Installation GRUB auf Boot-Partition (grub2-install /dev/sda3)
	[x] Qubes: Sicherung des MBR von Qubes auf USB (dd if=/dev/sda of=sda.mbr bs=512 count=1)
	           qvm-copy-to-vm sys-usb sda.mbr
	[x] Windows: Wiederherstellung Windows MBR mit Boot-Stick und bootrec /fixmbr
	[x] Windows: EasyBCD: Hinzufügen Qubes zum Bootmenü mit Verweis auf Boot-Partition
	             Disable "Use Metro Bootloader" + Enable "Wait for selection"
	[x] Windows: Qubes MBR umbenennen/kopieren nach C:\NST\AutoNeoGrub0.mbr
	             sda.mbr -> AutoNeoGrub0.mbr
[x] Coreboot installieren
[x] Bitlocker aktivieren
	[x] Lokale Gruppenrichtlinie ändern: Allow PIN
	[x] Verschlüsselung mit setzen einer PIN aktivieren
```
