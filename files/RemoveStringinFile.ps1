param($path,$ip)
try
{
    $data = Get-Content "$path" | Where-Object {$_ -replace "$ip"} 
    $data  | Set-Content "$path"
 }
  catch
    {
   
       throw "Unable to Remove ip $ip error: $_.exception.message"
       return $false
    }
