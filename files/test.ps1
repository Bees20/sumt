param($dnsip,$domain,$name,$ipaddress)
'c:\\windows\\system32\\dnscmd.exe ' $dnsip /RecordAdd $domain $name A $ipaddress
