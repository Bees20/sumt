setup.exe /Q /IACCEPTSQLSERVERLICENSETERMS /SQLSVCACCOUNT="{{ domain_user }}" /SQLSVCPASSWORD="{{ domain_pwd }}" /AGTSVCACCOUNT="{{ domain_user }}" /AGTSVCPASSWORD="{{ domain_pwd }}" /SAPWD="{{ sa_pwd }}" /ISSVCACCOUNT="{{ domain_user }}" /ISSVCPASSWORD="{{ domain_pwd }}" /ConfigurationFile="{{ config_path }}"
