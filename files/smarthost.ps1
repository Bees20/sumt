param($vmName,$FQDN,$smarthost)
try
{
Import-Module WebADministration -Force
Write-Host "Importing Web Administration Module"
$SMTPSvc = [ADSI]"IIS://$vmName/smtpsvc/1"
$SMTPSvc.SmartHost = "$smarthost"
Write-Host "Set SmartHost to $smarthost"
$SMTPSvc.FullyQualifiedDomainName="$fqdn"
Write-Host "Set FQDN to $fqdn"
$SMTPSvc.SetInfo()
Get-Service -Name "SMTPSVC" -ComputerName $vmName | Set-Service -StartupType automatic
Write-Host "Set the SMTP service Startup Type to Automatic"
Get-Service -Name "SMTPSVC" -ComputerName $vmName | Set-Service -Status running
Write-Host "Starting the SMTP service"
Start-Sleep -s 10
Write-Host "Started the SMTP service"
$ipblock= @(24,0,0,128,
32,0,0,128,
60,0,0,128,
68,0,0,128,
1,0,0,0,
76,0,0,0,
0,0,0,0,
0,0,0,0,
1,0,0,0,
0,0,0,0,
2,0,0,0,
1,0,0,0,4,0,0,0,0,0,0,0,76,0,0,128,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,255,255,255,255)
$ipList = @()
$octet = @()
$ipList = "127.0.0.1"
$octet += $ipList.Split(".")
$ipblock[36] +=1
$ipblock[44] +=1;
$smtpserversetting = get-wmiobject -namespace root\MicrosoftIISv2 -computername localhost -Query "Select * from IIsSmtpServerSetting"
$ipblock += $octet
$smtpserversetting.RelayIpList = $ipblock
$smtpserversetting.put()
$iisObject = new-object System.DirectoryServices.DirectoryEntry("IIS://localhost/SmtpSvc/1")
$iisObject.Properties["smarthosttype"].Value = "2";
$iisObject.CommitChanges()
$iisObject.setinfo()
}
catch
{
  throw $_.exception.message
}
