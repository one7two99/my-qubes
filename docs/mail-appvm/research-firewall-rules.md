Open a new terminal and setup a watch job which run every second and shows you which connections are opened.
If the AppVM opens a connection you can now see this in the terminal window for the time the connection is initialized and established.

```
watch -n 1 'sudo netstat -natp'
```
Options:
-n --numeric = numeric, show IP and Port numbers
-t --tcp = show only TCP sockets
-p --program = show process ID and process name (needs sudo for other processes)
-a --all = show open ports and connections


How to find IPs from your email provider
========================================
https://support.google.com/a/answer/60764?hl=de

1) Check the SPF-entry of your email-provider
   this will show a list of domains which are included as SPF-entries
```
[user@my-privmail ~]$ nslookup -q=TXT _spf.google.com 8.8.8.8
Server:		8.8.8.8
Address:	8.8.8.8#53

Non-authoritative answer:
_spf.google.com	text = "v=spf1 include:_netblocks.google.com include:_netblocks2.google.com include:_netblocks3.google.com ~all"

Authoritative answers can be found from:
```

2) check the DNS-entries for those SPF-domains. The answer will give the real adress space of the mailservers
   Run the following command for every entry which you got as reply in step 1)
```
[user@my-privmail ~]$ nslookup -q=TXT _netblocks.google.com 8.8.8.8
Server:		8.8.8.8
Address:	8.8.8.8#53

Non-authoritative answer:
_netblocks.google.com	text = "v=spf1 ip4:64.233.160.0/19 ip4:66.102.0.0/20 ip4:66.249.80.0/20 ip4:72.14.192.0/18 ip4:74.125.0.0/16 ip4:108.177.8.0/21 ip4:173.194.0.0/16 ip4:209.85.128.0/17 ip4:216.58.192.0/19 ip4:216.239.32.0/19 ~all"

Authoritative answers can be found from:
```

3) You can use those IPs including the netmask to tweak your firewall settings.






Outlook.com
===========
```
nslookup -q=TXT spf.protection.outlook.com 8.8.8.8
nslookup -q=TXT spfa.protection.outlook.com 8.8.8.8
nslookup -q=TXT spfb.protection.outlook.com 8.8.8.8
```

ip4:207.46.100.0/24
ip4:207.46.163.0/24
ip4:65.55.169.0/24
ip4:157.56.110.0/23
ip4:157.55.234.0/24
ip4:213.199.154.0/24
ip4:213.199.180.128/26
ip4:157.56.112.0/24
ip4:207.46.51.64/26
ip4:64.4.22.64/26
ip4:40.92.0.0/14
ip4:40.107.0.0/17
ip4:40.107.128.0/17
ip4:134.170.140.0/24
ip4:23.103.128.0/19
ip4:23.103.198.0/23
ip4:65.55.88.0/24
ip4:104.47.0.0/17
ip4:23.103.200.0/21
ip4:23.103.208.0/21
ip4:23.103.191.0/24
ip4:216.32.180.0/23
ip4:94.245.120.64/26


Outlook.com IPs
https://support.office.com/en-us/article/office-365-urls-and-ip-address-ranges-8548a211-3fe7-47cb-abb1-355ea5aa88a2#bkmk_exo_ip
```
13.107.6.152/31
13.107.9.152/31
13.107.18.10/31
13.107.19.10/31
13.107.128.0/22
23.103.160.0/20
23.103.224.0/19
40.96.0.0/13
40.104.0.0/15
52.96.0.0/14
70.37.151.128/25
111.221.112.0/21
131.253.33.215/32
132.245.0.0/16
```

https://technet.microsoft.com/en-us/library/dn163583(v=exchg.150).aspx

```
23.103.132.0/22
23.103.144.0/22
40.92.0.0/18
40.93.0.0/18
40.94.0.0/18
40.95.0.0/18
40.107.0.0/18
52.100.0.0/18
52.101.0.0/18
52.102.0.0/18
52.103.0.0/18
94.245.120.64/27
104.47.0.0/19
157.55.234.0/24
157.56.112.0/24
213.199.154.0/24
213.199.180.128/26
```

http://download.priasoft.com/office365/Office365_EndPoints.html




Gmail IPs
=========

https://briansnelson.com/How_to_find_GMAIL_IPs_to_allow_at_Firewall#IPV4_IPs_for_Google
64.18.0.0/20
64.233.160.0/19
66.102.0.0/20
66.249.80.0/20
72.14.192.0/18
74.125.0.0/16
108.177.8.0/21
173.194.0.0/16
207.126.144.0/20
209.85.128.0/17
216.58.192.0/19
216.239.32.0/19 

30.03.18
========

ip4:64.233.160.0/19
ip4:66.102.0.0/20
ip4:66.249.80.0/20
ip4:72.14.192.0/18
ip4:74.125.0.0/16
ip4:108.177.8.0/21
ip4:173.194.0.0/16
ip4:209.85.128.0/17
ip4:216.58.192.0/19
ip4:216.239.32.0/19      
ip4:172.217.0.0/19
ip4:172.217.32.0/20
ip4:172.217.128.0/19
ip4:172.217.160.0/20
ip4:172.217.192.0/19
ip4:108.177.96.0/19    
