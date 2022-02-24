param($name,$zone,$ipaddress,$dnsip)
try
 {
   Add-DnsServerResourceRecordA -Name "$name" -ZoneName "$zone" -IPv4Address "$ipaddress" -TimeToLive 01:00:00  -ComputerName "$dnsip"
  }
  catch
    {

       throw "Unable to create DNS record $name and IP $ipaddress error: $_.exception.message"
    }

