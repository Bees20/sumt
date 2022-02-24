param ($username,$password,$domain,$oupath,$identity)
if((@(Get-ADUser -Filter { SamAccountName -eq $username }).Count -eq 0))
{

  try
   {
      New-ADUser -Name "$username" -Path "$oupath" -AccountPassword (ConvertTo-SecureString -AsPlainText "$password" -Force) -PasswordNeverExpires $true -ChangePasswordAtLogon $false -Enabled $true -UserPrincipalName "$username@$domain"

      Add-ADGroupMember -Identity "$identity" -Members "$username"
   }
  catch
    {
   
       throw "Unable to create user $username error: $_.exception.message"
    }
}
