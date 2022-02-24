#This script will Generate script for IIS log purge and schedule the job 
#IIS log file purge script will be copied to the server when server is built

$scriptpath = (Get-WebConfigurationProperty '/system.applicationHost/sites/site[1]' -Name 'logfile.directory').Value
New-Item -Path $scriptpath -ItemType dir -Force
$ValidPath = Test-Path $scriptpath -IsValid

If (Test-Path $scriptpath\IISLogPurge.ps1) {
	Remove-Item $scriptpath\IISLogPurge.ps1
}

If ($ValidPath -eq $True) {
    "#ISS Log Purge script is used to delete the logs which older than 15 days." |  Out-File -FilePath "$scriptpath\IISLogPurge.ps1" -Encoding unicode
    "`$scriptpath = (Get-WebConfigurationProperty '/system.applicationHost/sites/site[1]' -Name 'logfile.directory').Value" |  Out-File -append -FilePath "$scriptpath\IISLogPurge.ps1" -Encoding unicode
    "`$maxDaystoKeep = -15" |  Out-File -append -FilePath "$scriptpath\IISLogPurge.ps1" -Encoding unicode
    "`$outputPath = `"`$scriptpath\Cleanup_Old_logs.log`" "|  Out-File -append -FilePath "$scriptpath\IISLogPurge.ps1" -Encoding unicode
  
    "`$itemsToDelete = dir `$scriptpath -Recurse -File *.log | Where LastWriteTime -lt ((get-date).AddDays(`$maxDaystoKeep)) | % { `$_.FullName }" |  Out-File -append -FilePath "$scriptpath\IISLogPurge.ps1" -Encoding unicode
    "IF (`$itemsToDelete.Count -gt 0){"|  Out-File -append -FilePath "$scriptpath\IISLogPurge.ps1" -Encoding unicode
        "ForEach (`$item in `$itemsToDelete){" |  Out-File -append -FilePath "$scriptpath\IISLogPurge.ps1" -Encoding unicode
            "`"`$(`$item) is older than `$((get-date).AddDays(`$maxDaystoKeep)) and will be deleted `" | Add-Content `$outputPath" |  Out-File -append -FilePath "$scriptpath\IISLogPurge.ps1" -Encoding unicode
            "Get-item `$item | Remove-Item -Verbose" |  Out-File -append -FilePath "$scriptpath\IISLogPurge.ps1" -Encoding unicode
        "}" |  Out-File -append -FilePath "$scriptpath\IISLogPurge.ps1" -Encoding unicode
    "}" |  Out-File -append -FilePath "$scriptpath\IISLogPurge.ps1" -Encoding unicode
    "ELSE{" |  Out-File -append -FilePath "$scriptpath\IISLogPurge.ps1" -Encoding unicode
	    "`"No items to be deleted today `$(`$(Get-Date).DateTime)`" | Add-Content `$outputPath"  |  Out-File -append -FilePath "$scriptpath\IISLogPurge.ps1" -Encoding unicode
    "}" |  Out-File -append -FilePath "$scriptpath\IISLogPurge.ps1" -Encoding unicode
   
    "Write-Output 'Cleanup of log files older than `$((get-date).AddDays(`$maxDaystoKeep)) completed...'" |  Out-File -append -FilePath "$scriptpath\IISLogPurge.ps1" -Encoding unicode
    "start-sleep -Seconds 10" |  Out-File -append -FilePath "$scriptpath\IISLogPurge.ps1" -Encoding unicode
}
Else 
{
    Throw "$scriptpath is not exist in the system."
}

$jobname = "Schedule job for IIS log purge"
$script =  "$scriptpath\IISLogPurge.ps1"
$scriptblock = [scriptblock]::Create($script)
$trigger = New-JobTrigger -Daily -At 11:00PM

Get-ScheduledJob -Name $jobname -ErrorAction "SilentlyContinue" | Unregister-ScheduledJob -Force

If (Test-Path $scriptpath\IISLogPurge.ps1) {
	Register-ScheduledJob -Name $jobname -ScriptBlock $scriptblock  -Trigger $trigger
}
Else 
{
    Throw "scriptpath\IISLogPurge.ps1 file does not exists in the system."
}

if (Get-ScheduledJob -Name $jobname) {
	Write-Host "Job successfully scheduled on target server"
} 
Else
{
	Throw "Error scheduling IIS Log File Cleanup job on target server"
}

