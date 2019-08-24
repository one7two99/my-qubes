```
Download driver and run installer
https://support.brother.com/g/b/downloadhowto.aspx?c=eu_ot&lang=en&prod=mfcl2710dw_us_eu_as&os=127&dlid=dlf006893_000&flang=4&type3=625

# Create a new printer template

gunzip linux-brprinter-installer*
rm linux-brprinter-installer*.gz
chmod +x linux-brprinter-installer*
bash linux-brprinter-installer* MFC-L2710DW

# create a new AppVM, which will be used a disposable VM
PrintVMtemplate=t-fedora-29-print
DispPrintVM=my-print

qvm-create --template $PrintVMtemplate --label orange --property template_for_dispvms=True --class=AppVM $DispPrintVM
qvm-features $DispPrintVM appmenus-dispvm 1
qvm-sync-appmenus --regenerate-only $DispPrintVM

#to start for example a browser-window in the disposable Printer VM
qvm-run --dispvm=$DispPrintVM --service qubes.StartApp+firefox

```
