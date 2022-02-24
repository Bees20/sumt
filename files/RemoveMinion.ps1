Invoke-command -Scriptblock {& cmd.exe /K "C:\\salt\\uninst.exe /S"}
Start-sleep -Seconds 60
Remove-Item "C:\\salt" -Recurse -Force
while(Test-Path -Path "C:\\salt")
{
  Remove-Item -Path "C:\\salt" -Recurse -Force
}
Start-sleep -Seconds 30
Get-NetIPInterface -AddressFamily IPv4 -InterfaceAlias "Ethernet*"| Remove-NetRoute -Confirm:$false
Get-NetIPInterface -AddressFamily IPv4 -InterfaceAlias "Ethernet*" | Set-NetIPInterface -Dhcp Enabled
Restart-NetAdapter (Get-NetIPInterface -AddressFamily IPv4 -InterfaceAlias "Ethernet*")
