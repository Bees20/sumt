try
{
  [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SqlWmiManagement')| Out-Null
  $StartupParameters = @('-dD:\mssql\data\master.mdf','-lG:\mssql\logs\mastlog.ldf')
  [bool]$SystemPaths = $false

#Use wmi to change account
  $smowmi = New-Object Microsoft.SqlServer.Management.Smo.Wmi.ManagedComputer $env:computername
  $wmisvc = $smowmi.Services | Where-Object {$_.Name -eq 'MSSQLSERVER'}
  Write-Host "Old Parameters for $env:computername :"
  Write-Host $wmisvc.StartupParameters
  #$location = ($wmisvc.StartupParameters -split ';' | Select-Object -First 1).replace('-d','').replace('\master.mdf','')
  $location = "N:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA"
  Copy-Item -Path "$location\*.mdf" -Destination "D:\mssql\data\" -Force
  Copy-Item -Path "$location\*.ldf" -Destination "G:\mssql\logs\" -Force
#Updated params with existing startup params (-d,-e,-l)
  $oldparams = $wmisvc.StartupParameters -split ';'
  $newparams = @()
  foreach($param in $StartupParameters)
   {
    if($param.Substring(0,2) -match '-d|-e|-l')
    {
      $SystemPaths = $true
      $newparams += $param
      $oldparams = $oldparams | Where-Object {$_.Substring(0,2) -ne $param.Substring(0,2)}
      }
      else
       {
          $newparams += $param
         }
       }

   $newparams += $oldparams | Where-Object {$_.Substring(0,2) -match '-d|-e|-l'}
   $paramstring = ($newparams | Sort-Object) -join ';'
   Write-Host "New Parameters for $env:computername :"
   Write-Host $paramstring
   $wmisvc.StartupParameters = $paramstring
   $wmisvc.Alter()
   Write-Warning "Startup Parameters for $env:computername updated. You will need to restart the service for these changes to take effect."
 If($SystemPaths){

    Write-Warning "You have changed the system paths for $env:computername. Please make sure the paths are valid before restarting the service"
 
    }
}
catch
{
   Write-Error $_.exception.message
  }

net start SQLSERVERAGENT
net start MSSQLSERVER
