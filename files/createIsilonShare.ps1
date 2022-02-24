param($sitekey,$isilonshare)
try
{
  if(!(Test-Path $isilonshare)) 
   { 
	 New-Item $isilonshare -type Directory 
	 if(!(Test-Path $isilonshare/$sitekey))
	   {
		 New-Item $isilonshare/$sitekey -type Directory
		}		 
	 }
	else
	{
	  if(!(Test-Path $isilonshare/$sitekey))
		{
		  New-Item $isilonshare/$sitekey -type Directory
		  Write-Host "Successfully created isilon share for $sitekey"
		  }
	    else
		 {
		    Write-Host "Isilon share already exists for $sitekey..reusing it"
		   }
	  }
    if(!(Test-Path $isilonshare/$sitekey))
     {
       throw "Unable to create isilon share for $sitekey"
      }
 }
catch
 {
    throw "Unable to create isilon share for $sitekey"
  }
