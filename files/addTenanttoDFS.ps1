param($share,$naspath,$sitekey)

if (!(Get-DfsnFolder -Path $share -ErrorAction SilentlyContinue))
 { 
    New-DfsnFolderTarget -Path $share -TargetPath $nasPath\$sitekey 
   }
else
 { 
   if (Get-DfsnFolderTarget -Path $share -TargetPath $nasPath\$sitekey -ErrorAction SilentlyContinue)
    { 
      write-host DfsnFolder exists with the correct target. Reusing 
      }
   else
    { 
       throw "DfsnFolder $share exists, but the target is not $nasPath\$sitekey. Please investigate"
      } 
  }
