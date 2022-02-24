#Requires -RunAsAdministrator

		$7zippath =Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | ?{$_.DisplayName -like "7-Zip*"} | Select InstallLocation
		$7ziplocation= $7zippath.InstallLocation
		if ([string]::IsNullOrEmpty($7ziplocation))
		{
		$7ziplocation = "$env:ProgramFiles\7-Zip"
		}
		$7ziplocation= Join-Path -Path "$7ziplocation" "7z.exe"
		Set-Alias sz "$7ziplocation";
		Write-Host "7-Zip location is : $7ziplocation"
	


		Push-Location
		if (!(Get-Module "sqlps"))
		{
		Import-Module "sqlps" -DisableNameChecking;
		}
		Pop-Location
		
		function createTempFile($FileName)
		{

		if (Test-Path "$FileName")
		{
		Remove-Item -Path "$FileName" -Force
		}
		if (!(Test-Path "$FileName"))
		{
		New-Item -Path "$FileName" -ItemType File -Force
		}
		}
		
	  function Get-7ZipContent
		{
			begin
			{
			$Regex = "^(\S+)\s+(\S+)\s+(\S+)\s+(\d+)\s+(\d+)\s+([\S| ]+)"
			$Props = {
			@{
			Date = $Matches[1] -as [DateTime]
			Time = $Matches[2] -as [String]
			Attr = $Matches[3] -as [String]
			Size = $Matches[4] -as [Int]
			Compressed = $Matches[5] -as [Int]
			Name = $Matches[6] -as [String]
			}
			}

			$Proplist = $Props.ToString().Split("`n") -match "^\s*(\S+)\s*=.+$" -replace "^\s*(\S+)\s*=.+$",'$1'
			}

			process
			{
			if ($_ -match $Regex)
			{
			New-Object PSObject -Property (&$props) | Select-Object $PropList
			}
			}
		}
		
		function ValidateUnzip
		{
		 param ( 
            [string]$zippath, 
            [string]$folderpath
           ) 
		
			$listoutput = sz l $zippath
			$listoutput = $listoutput | Get-7ZipContent | Select -Property "Size"
			$Size = 0
			for($cnt = 0 ; $cnt -lt $listoutput.Count-1; $cnt++)
			{
			$Size = $Size+ $listoutput[$cnt].Size;
			}
      if($Size -ne 0)
      {
				$Size1 = "{0:N2} " -f ((Get-ChildItem $folderpath -Recurse | Measure-Object -Property Length -Sum -ErrorAction Stop).Sum )
      }
      else
      {
				$Size1=0
      }
			if($Size -eq $Size1)
			{
				return $true;
			}
			else
			{
				return $false;
			}
		}
    
  function GetLargestVersion
{
    param 
	(
	[Parameter(Mandatory = $true)][string] $V1,
	[Parameter(Mandatory = $true)][string] $V2
	)

	$_V1=$V1.Replace("-",".").Replace("_",".")
	$_V2=$V2.Replace("-",".").Replace("_",".")
	$_V1dotCount = ($_V1.ToCharArray() | Where-Object {$_ -eq '.'} | Measure-Object).Count
	$_V2dotCount = ($_V2.ToCharArray() | Where-Object {$_ -eq '.'} | Measure-Object).Count

	if($_V1dotCount -le 3 -and $_V2dotCount -le 3)
	{ 
		if([System.Version]"$_V1" -gt  [System.Version]"$_V2")
		 {
			return $V1;
		 }
		else
		{
			return $V2;
		}
	}
	else
	{
		$V1Arr=$_V1.Split(".")
		$V2Arr=$_V2.Split(".")
        $largestdots;
        if($V1Arr.Count -gt $V2Arr.Count)
        {
            $largestdots=$V1Arr.Count;
        }
        else
        {
            $largestdots=$V2Arr.Count;
        }
		$eq = 0;

			for($i=0;$i -lt $largestdots;$i++)
			{
				if($V1Arr[$i] -gt $V2Arr[$i])
					{
						return $V1
					}
				if($V2Arr[$i] -gt $V1Arr[$i])
					{
						return $V2
					}
				if($V1Arr[$i] -eq $V2Arr[$i])
				{
					$eq=1
				}
        
			}

			if($eq -eq 1)
			{
			return $V1
			}
	}
}

	
                $TARGET_PATCH_VERSION="{{PATCH_VERSION}}"
		if($TARGET_PATCH_VERSION -eq "None")
                {
                $TARGET_PATCH_VERSION=""
                }
              
    $FileName = "{{FILE_TEMP}}\{{BUILD}}_{{ROLE}}.txt";
    createTempFile($FileName);				
	  
	  $currentprincipal = [System.Security.Principal.WindowsIdentity]::GetCurrent();
    $currentuserwithdomain = $currentprincipal.Name.split("\");
    $name = $currentuserwithdomain[1];
    try {$groups = $currentprincipal.Groups | %{ $_.Translate([System.Security.Principal.NTAccount]) }} catch {}
    $Folder = "{{PACKAGE_SHARE}}\{{BUILD}}\{{ROLE}}.zip"
    $User = $name
    $permission = (Get-Acl $Folder).Access | ?{$_.IdentityReference -match $User -or $groups -contains $_.IdentityReference} | Select IdentityReference,FileSystemRights
    If ($permission)
		{
    $permission | % {Write-Host "User $($_.IdentityReference) has '$($_.FileSystemRights)' rights on folder $folder"}
    }
    Else 
		{
    throw("The current user doesn't have the previlages to access the Package_share folder or the pacakge share location is not shared");
    }
		
		$ValidateUnzip="0"
		if (!(Test-Path "{{PACKAGE_ROOT}}\{{BUILD}}\{{ROLE}}\Installer\{{ROLE}}_Workflows.psm1"))
		{
			if(![System.IO.File]::Exists("{{PACKAGE_SHARE}}\{{BUILD}}\{{ROLE}}.zip"))
			{
			throw("Please Check The Package_share location , it doesn't exists or  it is not shared  ");
			}
		Write-Host "COPY  PACKAGE FROM DROP SHARE" -foregroundcolor "black" -backgroundcolor "yellow";
		New-Item -ItemType Directory -Force -Path "{{PACKAGE_ROOT}}\{{BUILD}}\{{ROLE}}" | Out-Null;
		Copy-Item -Confirm:$false -Destination "{{PACKAGE_ROOT}}\{{BUILD}}\{{ROLE}}.zip" -Force -Path "{{PACKAGE_SHARE}}\{{BUILD}}\{{ROLE}}.zip";
		Write-Host "UNZIP  PACKAGE FROM DROP SHARE" -foregroundcolor "black" -backgroundcolor "yellow";
    if (-not (test-path "$7ziplocation")) {throw "$7ziplocation needed";}    
    Write-Host "logging .zip Package Unzip  progress to $FileName";
    sz x "{{PACKAGE_ROOT}}\{{BUILD}}\{{ROLE}}.zip" $("-o" + "{{PACKAGE_ROOT}}\{{BUILD}}\{{ROLE}}") -bsp1 > $FileName
    Write-Host "CLEAN UP  PACKAGE" -foregroundcolor "black" -backgroundcolor "yellow";
		Remove-Item "{{PACKAGE_ROOT}}\{{BUILD}}\{{ROLE}}.zip" -Confirm:$false -Force;
		
	
		if(ValidateUnzip -zippath "{{PACKAGE_SHARE}}\{{BUILD}}\{{ROLE}}.zip" -folderpath "{{PACKAGE_ROOT}}\{{BUILD}}\{{ROLE}}")
		{
			Write-Host "Unzip Validation completed"
		}
		else
		{
			Write-Host "Unzip Validation failed";
			Write-Host "Deleting  {{PACKAGE_ROOT}}\{{BUILD}}\{{ROLE}}";
			Remove-Item "{{PACKAGE_ROOT}}\{{BUILD}}\{{ROLE}}" -Confirm:$false -Recurse -Force;
			throw("package is not unzipped properly. Unzip validation failed.")
		}
	
		
	}
	else 
	{
		if($ValidateUnzip -eq "1")
			{
				
	
		if(ValidateUnzip -zippath "{{PACKAGE_SHARE}}\{{BUILD}}\{{ROLE}}.zip" -folderpath "{{PACKAGE_ROOT}}\{{BUILD}}\{{ROLE}}")
		{
			Write-Host "Unzip Validation completed"
		}
		else
		{
			Write-Host "Unzip Validation failed";
			Write-Host "Deleting  {{PACKAGE_ROOT}}\{{BUILD}}\{{ROLE}}";
			Remove-Item "{{PACKAGE_ROOT}}\{{BUILD}}\{{ROLE}}" -Confirm:$false -Recurse -Force;
			throw("package is not unzipped properly. Unzip validation failed.")
		}
	
			}
		
	}		
  if (Test-Path "{{PACKAGE_ROOT}}\{{BUILD}}\{{ROLE}}\Installer\{{ROLE}}_Workflows.psm1")
  {
    Write-Host "package is copied successfully"
  }
  else
  {
    throw("Package is not copied to the desired location please check the package_share location");
  }
		
	 
    #Step 1: Provision all the neces{{UDAC_USER}}ry roles on this server
    Import-Module "{{PACKAGE_ROOT}}\{{BUILD}}\{{ROLE}}\Installer\{{ROLE}}_Workflows.psm1" -ArgumentList "{{FILE_TEMP}}", "AddTenant{{WORKFLOW}}_{{ROLE}}_{{SERVER}}_{{CLUSTER}}";
		
			
				Write-Host "RUNNING {{WORKFLOW}}  for tenant {{TENANT}}" -foregroundcolor "black" -backgroundcolor "yellow";
			$query = "EXEC AddorUpdateTenantVersion_v17_1 '{{TENANT}}' , '{{ROLE}}', '{{BUILD}}', '{{PATCH_VERSION}}', '{{WORKFLOW}}', 'STARTED'";
		try{
		SumTInvoke-SqlReader -Query $query -ServerInstance "{{UDAC_SERVER}}" -Database "{{UDAC_DB}}" -Username "{{UDAC_USER}}" -Password "{{UDAC_PASS}}" -QueryTimeout 0

		}
		catch
		{
		Write-Host "$_.Exception.Message" -BackgroundColor Red
		throw("Unable to run $query");
		break;
		}
	$query = "SELECT dbo.GET_PS_INSTALL_PARAMETERS( '{{SERVER}}', '{{CLUSTER}}', NULL , '{{WORKFLOW}}', '{{ROLE}}', '{{TENANT}}' )";
		try{
		$InstallParameters =
		SumTInvoke-SqlReader -Query $query -ServerInstance "{{UDAC_SERVER}}" -Database "{{UDAC_DB}}" -Username "{{UDAC_USER}}" -Password "{{UDAC_PASS}}" -QueryTimeout 0

		}
		catch
		{
		Write-Host "$_.Exception.Message" -BackgroundColor Red
		throw("Unable to run $query");
		break;
		}
	

			$config = New-Object XML
		$config.LoadXml($InstallParameters.Column1)

				if(![string]::IsNullOrWhiteSpace($TARGET_PATCH_VERSION))
				{
				foreach($Item in $config.overrides.Key)
				{
				if($Item.name -eq "TARGET_PATCH_VERSION")
				{
				$Item.SetAttribute("value",$TARGET_PATCH_VERSION)
				}
				}
				}

	  

    $timer = [Diagnostics.Stopwatch]::StartNew();
    $obj_status = "";
    $obj_message = "";
    $obj_errordetail = "";

    if (!(({{ROLE}}_{{WORKFLOW}}_PreValidate($config.InnerXml))[-1]))
    {
    $obj_errordetail = $_.Exception.Message; $obj_status = "ERROR"; $obj_message = "PreValidate Failed";
    }
    else
    {
    if (!(({{ROLE}}_{{WORKFLOW}}_PreExecute($config.InnerXml))[-1]))
    {
    $obj_errordetail = $_.Exception.Message; $obj_status = "ERROR"; $obj_message = "PreExecute Failed";
    }
    else
    {
    if (!(({{ROLE}}_{{WORKFLOW}}_Execute($config.InnerXml))[-1]))
    {
    $obj_errordetail = $_.Exception.Message; $obj_status = "ERROR"; $obj_message = "Execute Failed";
    }
    else
    {
    if (!(({{ROLE}}_{{WORKFLOW}}_PostExecute($config.InnerXml))[-1]))
    {
    $obj_errordetail = $_.Exception.Message; $obj_status = "ERROR"; $obj_message = "PostExecute Failed";
    }
    else
    {
    if (!(({{ROLE}}_{{WORKFLOW}}_PostValidate($config.InnerXml))[-1]))
    {
    $obj_errordetail = $_.Exception.Message; $obj_status = "ERROR"; $obj_message = "PostValidate Failed";
    }
    else
    {
    $obj_status = "OK";
    }
    }
    }
    }
    }

    $timer.Stop();

    $obj = [PSCustomObject]@{
    Name= $obj_name;
    Status= $obj_status;
    Message= $obj_message;
    ErrorDetail= $obj_errordetail;
    Seconds= $timer.Elapsed.TotalSeconds;
    };

    if($obj_status -eq "OK")
    {

    $patchVersionCheck = $true

    
  

    if(![string]::IsNullOrWhiteSpace($TARGET_PATCH_VERSION))
    {
    $query = "SELECT DBO.GET_EXPECTED_PATCH_BYROLE ('$TARGET_PATCH_VERSION','PATCH_TENANT','{{ROLE}}')";
		try{
		$patchversion =
		SumTInvoke-SqlReader -Query $query -ServerInstance "{{UDAC_SERVER}}" -Database "{{UDAC_DB}}" -Username "{{UDAC_USER}}" -Password "{{UDAC_PASS}}" -QueryTimeout 0

		}
		catch
		{
		Write-Host "$_.Exception.Message" -BackgroundColor Red
		throw("Unable to run $query");
		break;
		}
	
      $TARGET_PATCH_VERSION = $patchversion.Column1
	  if(![string]::IsNullOrWhiteSpace($TARGET_PATCH_VERSION))
	  {
      $patchVersionCheck = DoesPatchVersionExists -Package '{{BUILD}}' -ParameterXmlString $config -Role '{{ROLE}}' -Version $TARGET_PATCH_VERSION -SiteKey '{{TENANT}}'   
	  }
		
		
    if($patchVersionCheck -eq $false)
    {
    $TARGET_PATCH_VERSION = ''
    }
    }
    $query = "EXEC AddorUpdateTenantVersion_v17_1 '{{TENANT}}' , '{{ROLE}}', '{{BUILD}}', '$TARGET_PATCH_VERSION', '{{WORKFLOW}}', 'COMPLETED'";
		try{
		SumTInvoke-SqlReader -Query $query -ServerInstance "{{UDAC_SERVER}}" -Database "{{UDAC_DB}}" -Username "{{UDAC_USER}}" -Password "{{UDAC_PASS}}" -QueryTimeout 0

		}
		catch
		{
		Write-Host "$_.Exception.Message" -BackgroundColor Red
		throw("Unable to run $query");
		break;
		}
	
				 Write-Host "COMPLETED {{WORKFLOW}} for tenant {{TENANT}}" -foregroundcolor "black" -backgroundcolor "green";
			
    }
    else
    {
    $query = "EXEC AddorUpdateTenantVersion_v17_1 '{{TENANT}}' , '{{ROLE}}', '{{BUILD}}', '$TARGET_PATCH_VERSION', '{{WORKFLOW}}', '$obj_status : $obj_message : $obj_errordetail'";
		try{
		SumTInvoke-SqlReader -Query $query -ServerInstance "{{UDAC_SERVER}}" -Database "{{UDAC_DB}}" -Username "{{UDAC_USER}}" -Password "{{UDAC_PASS}}" -QueryTimeout 0

		}
		catch
		{
		Write-Host "$_.Exception.Message" -BackgroundColor Red
		throw("Unable to run $query");
		break;
		}
	
				Write-Host "ERROR occured while running {{WORKFLOW}}  for tenant : {{TENANT}} : $obj_message : $obj_errordetail" -foregroundcolor "black" -backgroundcolor "red";
				throw("Error while executing powershell");
	
    }
  
