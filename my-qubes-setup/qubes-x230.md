# USB and PCI devices in the Lenovo X230
this page lists all devices in the lenovo x230 which you can attach to your AppVMs.

## PCI devices

- 00:00.0 Host bridge: Intel Corporation 3rd Gen Core processor DRAM Controller (rev 09)
- 00:1f.0 ISA bridge: Intel Corporation QM77 Express Chipset LPC Controller (rev 04)
- 00:1f.2 SATA controller: Intel Corporation 7 Series Chipset Family 6-port SATA Controller [AHCI mode] (rev 04)
- 00:1f.3 SMBus: Intel Corporation 7 Series/C216 Chipset Family SMBus Controller (rev 04)
- 00:1c.0 PCI bridge: Intel Corporation00:00.0 Host bridge: Intel Corporation 3rd Gen Core processor DRAM Controller (rev 09)
- 00:1c.1 PCI bridge: Intel Corporation 7 Series/C210 Series Chipset Family PCI Express Root Port 2 (rev c4)
- 00:14.0 USB controller: Intel Corporation 7 Series/C210 Series Chipset Family USB xHCI Host Controller (rev 04)
- 00:1a.0 USB controller: Intel Corporation 7 Series/C216 Chipset Family USB Enhanced Host Controller #2 (rev 04)
- 00:1d.0 USB controller: Intel Corporation 7 Series/C216 Chipset Family USB Enhanced Host Controller #1 (rev 04)
- 00:02.0 VGA compatible controller: Intel Corporation 3rd Gen Core processor Graphics Controller (rev 09)
- 00:16.0 Communication controller: Intel Corporation 7 Series/C216 Chipset Family MEI Controller #1 (rev 04)
- 00:1b.0 Audio device: Intel Corporation 7 Series/C216 Chipset Family High Definition Audio Controller (rev 04)
- 02:00.0 System peripheral: Ricoh Co Ltd PCIe SDXC/MMC Host Controller (rev 07)
- 03:00.0 Network controller: Intel Corporation Centrino Advanced-N 6205 [Taylor Peak] (rev 34)
- 00:19.0 Ethernet controller: Intel Corporation 82579LM Gigabit Network Connection (Lewisville) (rev 04)


## internal USB devices and mapping to external USB-Ports

### 1st USB 2.0 Controller - Enhanced Host Controller interface (EHCI)

00:1d.0 USB controller: Intel Corporation 7 Series/C216 Chipset Family USB Enhanced Host Controller #1 (rev 04)

    Bus 001 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
    Bus 002 Device 002: ID 8087:0024 Intel Corp. Integrated Rate Matching Hub
    Bus 002 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub


### 2nd USB 2.0 Controller - Enhanced Host Controller interface (EHCI)

00:1a.0 USB controller: Intel Corporation 7 Series/C216 Chipset Family USB Enhanced Host Controller #2 (rev 04)

    Bus 001 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
    Bus 002 Device 002: ID 8087:0024 Intel Corp. Integrated Rate Matching Hub
    Bus 002 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
    Bus 002 Device 004: ID 04f2:b2eb Chicony Electronics Co., Ltd = 720p HD Integrated camera
    Bus 002 Device 003: ID 0a5c:21e6 Broadcom Corp. BCM20702 Bluetooth 4.0 [ThinkPad]
    connects to: Right USB-Port (next to Ethernet-Port)

 

### USB 3.0 Controller - Extended Host Controller Interface (xHCI)

00:14.0 USB controller: Intel Corporation 7 Series/C210 Series Chipset Family USB xHCI Host Controller (rev 04)

    Bus 001 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
    Bus 002 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
    Bus 003 Device 001: ID 1d6b:0003 Linux Foundation 3.0 root hub
    Bus 002 Device 002: ID 0bdb:1926 Ericsson Business Mobile Networks BV 1 = LTE/WAN-Card
    connects to: Left USB-Port (next to VGA-Display-Out)
    connects to: Left USB-Port (next Mini-DisplayPort-Out)
