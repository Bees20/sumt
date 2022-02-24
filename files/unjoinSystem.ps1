param($domain,$username,$password)
if ((Get-WmiObject -Class Win32_ComputerSystem).PartOfDomain) 
{
   $pass = "$password" | ConvertTo-SecureString -asPlainText -Force
   $user = "$domain\$username"
   $credential = New-Object System.Management.Automation.PSCredential($user,$pass)

   Remove-Computer -Credential $credential -Force
}
else
{
  Write-Host "This system already removed from Domain"
}
