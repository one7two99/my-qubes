#Qubes Printing with a disposable PrinterVM

See also: https://www.qubes-os.org/doc/network-printer/

This Howto assumes that you're using the Brother MFC-L2710DW Laser-Printer which is a laserprinter, fax and scanner and works great with Linux for ~140 Euro.
```
# Create a new printer template
template=fedora-29
PrintVMtemplate=t-fedora-29-print
qvm-clone $template $PrintVMtemplate

#Download driver and copy to PrintVMtemplate
#https://support.brother.com/g/b/downloadhowto.aspx?c=eu_ot&lang=en&prod=mfcl2710dw_us_eu_as&os=127&dlid=dlf006893_000&flang=4&type3=625

#Install driver
qvm-run --auto --user root $PrintVMtemplate \
  'dnf install system-config-printer && \
   cd /home/user/QubesIncoming/* && \
   gunzip linux-brprinter-installer* && \
   rm linux-brprinter-installer*.gz && \
   chmod +x linux-brprinter-installer* && \
   bash linux-brprinter-installer* MFC-L2710DW'

#Print a test page

qvm-shutdown --wait $PrintVMtemplate

# create a new AppVM, which will be used a disposable VM
DispPrintVM=my-print

qvm-create --template $PrintVMtemplate --label orange --property template_for_dispvms=True --class=AppVM $DispPrintVM
qvm-features $DispPrintVM appmenus-dispvm 1
qvm-sync-appmenus --regenerate-only $DispPrintVM

#to start for example a browser-window in the disposable Printer VM
qvm-run --dispvm=$DispPrintVM --service qubes.StartApp+firefox

# to print a document: Opemn file oder Link in the disposable PrinterVM and print it from there.
```
