param ($cmdbServer,$cmdbDBName,$cmdbAdminUser,$cmdbAminPassword,$vmtierCode,$packageName,$tenantList)

$query= "select ck.[key],ckvt.VALUE,ck.id from CONFIGURATION_KEY_TO_VM_TIER ckvt 
join CONFIGURATION_KEY ck on ck.ID= ckvt.CONFIGURATION_KEY_ID
where (ck.[KEY] ='MATOMO_URL' or ck.[KEY]= 'MATOMO_SUPER_USER'or ck.[KEY]='MATOMO_SUPER_USER_PASSWORD' or ck.[KEY]='MATOMO_ENABLED' or ck.[KEY]='MATOMO_AUTH_TOKEN') and ckvt.VM_TIER_ID=(select id from VM_TIER where CODE='$vmtierCode')"

try
{

$id = Invoke-Sqlcmd -Query $query -ServerInstance $cmdbServer -Database $cmdbDBName -Username $cmdbAdminUser -Password $cmdbAminPassword

for ($i=0;$i -lt $id.Count;$i++)
{
  switch($id[$i].key)
  {
    'MATOMO_URL' {$matomourl=$id[$i].value}
    'MATOMO_SUPER_USER' {$matomosuperuser= $id[$i].value}
    'MATOMO_SUPER_USER_PASSWORD' {$matomopassword= $id[$i].value}
    'MATOMO_ENABLED' {$matomoenabled= $id[$i].value }
    'MATOMO_AUTH_TOKEN' {$matomauthtoken=$id[$i].value}
   }
}

if ($matomoenabled -eq 1)
{
	$matomourl='https://'+$matomourl
    for ($i=0;$i -lt $tenantList.count;$i++)
    {
           $sitename=$tenantList[$i]
           $query="select value from CONFIGURATION_KEY_TO_CUSTOMER_ENVIRONMENT ctck
                   inner join CUSTOMER_ENVIRONMENT ce on  ctck.CUSTOMER_ENVIRONMENT_ID= ce.ID
                   inner join CONFIGURATION_KEY  ck on ctck.CONFIGURATION_KEY_ID=ck.id
                   where ck.[KEY] in ('MATOMO_TENANT_SITEID','MATOMO_ENABLED') and ce.SITE_KEY='$sitename'"
           
           $id1 = Invoke-Sqlcmd -Query $query -ServerInstance $cmdbServer -Database $cmdbDBName -Username $cmdbAdminUser -Password $cmdbAminPassword
          
           $query= "select ceh.HOST_ADDRESS from CUSTOMER_ENVIRONMENT_HOST ceh
                    inner join CUSTOMER_ENVIRONMENT ce on ce.ID=ceh.CUSTOMER_ENVIRONMENT_ID
                     where ce.SITE_KEY='$sitename'"
           $id2 = Invoke-Sqlcmd -Query $query -ServerInstance $cmdbServer -Database $cmdbDBName -Username $cmdbAdminUser -Password $cmdbAminPassword
           $fqdn=$id2.HOST_ADDRESS
        
           if($id1.Count -eq 0)
           {
			 #$matomourl='https://'+$global:AllParams["MATOMO_URL"]
			 #$fqdn='https://'+$fqdn

			 $tokenauth=$matomauthtoken
             if($id2.count -eq 2)
             {
				 $fqdn='https://'+ $id2[0].HOST_ADDRESS
				 $fqdn2='https://'+ $id2[1].HOST_ADDRESS

				 $AddSiteURL=$matomourl+"/index.php?module=API&method=SitesManager.addSite&siteName=$sitename&urls[0]=$fqdn&urls[1]=$fqdn2&excludeUnknownUrls=1&&format=json&token_auth=$matomauthtoken"
             }
             else
			 {
				 $fqdn='https://' + $id2.HOST_ADDRESS
				 $AddSiteURL=$matomourl +"/index.php?module=API&method=SitesManager.addSite&siteName=$sitename&urls[0]=$fqdn&excludeUnknownUrls=1&&format=json&token_auth=$matomauthtoken"
             }
             $checkurl=$matomourl+"/index.php?module=API&method=SitesManager.getSitesIdFromSiteUrl&url=$fqdn&format=json&token_auth=$matomauthtoken"
             [Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"
             $response1= Invoke-RestMethod ($checkurl)
             if($response1.idsite -gt 0)
             {
				 write "site already added to matomo"
				 $siteid=$response1.idsite
             }
             else
             {
				 [Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"
				 $response= Invoke-RestMethod ($AddSiteURL)
				 $siteid=$response.value
             }
             $gettokenidURL=$matomourl +"/index.php/?module=API&method=SitesManager.getImageTrackingCode&idSite=$siteid&format=xml&token_auth=$matomauthtoken"
             [Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"
             $response= Invoke-RestMethod ($gettokenidURL)
             #$responsexml=[System.Xml.Linq.XDocument]::Parse($response.InnerXml)

             $responsexml=$response.InnerXml.ToString()
             $index=$responsexml.IndexOf('idsite')
             $responsexml=$responsexml.SubString($index)
            #$index= $index+7
             $index2=$responsexml.IndexOf('&')
             $index2=$index2-7
             $trackingid=$responsexml.substring(7,$index2)
             $query2="exec UpdateConfigKeyForTenant '$sitename','MATOMO_TENANT_SITEID','$trackingid'"
             Invoke-Sqlcmd -Query $query2 -ServerInstance $cmdbServer -Database $cmdbDBName -Username $cmdbAdminUser -Password $cmdbAminPassword
             echo "$sitename IQ: Matomo Configuration Finished"
          }
          else
		  {
			echo "$sitename IQ: Matomo Already Configured Or Matomo Enabled Is Set to False"
		  }
	}
   }
}
catch
 {
   throw "Unable to configure Matomo for Tenant $tenantList. Error $_.exception"

}

